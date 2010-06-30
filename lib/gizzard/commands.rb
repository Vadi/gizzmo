require "pp"
module Gizzard
  class Command
    include Thrift

    def self.run(command_name, *args)
      Gizzard.const_get("#{classify(command_name)}Command").new(*args).run
    end

    def self.classify(string)
      string.split(/\W+/).map{|s| s.capitalize }.join("")
    end

    attr_reader :service, :global_options, :argv, :command_options
    def initialize(service, global_options, argv, command_options)
      @service         = service
      @global_options  = global_options
      @argv            = argv
      @command_options = command_options
    end

    def help!(message = nil)
      raise HelpNeededError, message
    end
  end
  
  class SubtreeCommand < Command
    def run
      @roots = []
      argv.each do |arg|
        @id = ShardId.parse(arg)
        @roots << up(@id)
      end
      @roots.uniq.each do |root|
        puts root.to_unix
        down(root, 1)          
      end
    end
    
    def up(id)
      links = service.list_upward_links(id)
      if links.empty?
        id
      else
        links.map{|link| link.up_id }.find{|up_id| up(up_id) }
      end
    end

    def down(id, depth = 0)
      service.list_downward_links(id).map do |link|
        printable = "  " * depth + link.down_id.to_unix
        puts printable
        down(link.down_id, depth + 1)
      end
    end
  end

  class ReloadCommand < Command
    def run
      puts "Are you sure? Reloading will affect production services immediately! (Type 'yes')"
      if gets.chomp == "yes"
        service.reload_forwardings
      else
        STDERR.puts "aborted"
      end
    end
  end

  class DeleteCommand < Command
    def run
      argv.each do |arg|
        id  = ShardId.parse(arg)
        service.delete_shard(id)
        puts id.to_unix
      end
    end
  end

  class AddlinkCommand < Command
    def run
      up_id, down_id, weight = argv
      help! if argv.length != 3
      weight = weight.to_i
      up_id  = ShardId.parse(up_id)
      down_id  = ShardId.parse(down_id)
      link = LinkInfo.new(up_id, down_id, weight)
      service.add_link(link.up_id, link.down_id, link.weight)
      puts link.to_unix
    end
  end

  class UnlinkCommand < Command
    def run
      up_id, down_id = argv
      up_id  = ShardId.parse(up_id)
      down_id  = ShardId.parse(down_id)
      service.remove_link(up_id, down_id)
    end
  end

  class UnwrapCommand < Command
    def run
      shard_ids = argv
      help! "No shards specified" if shard_ids.empty?
      shard_ids.each do |shard_id_string|
        shard_id   = ShardId.parse(shard_id_string)
        service.list_upward_links(shard_id).each do |uplink|
          service.list_downward_links(shard_id).each do |downlink|
            service.add_link(uplink.up_id, downlink.down_id, uplink.weight)
            new_link = LinkInfo.new(uplink.up_id, downlink.down_id, uplink.weight)
            service.remove_link(uplink.up_id, uplink.down_id)
            service.remove_link(downlink.up_id, downlink.down_id)
            puts new_link.to_unix
          end
        end
        service.delete_shard shard_id
      end
    end
  end

  class CreateCommand < Command
    def run
      help! if argv.length != 3
      host, table, class_name = argv
      busy = 0
      source_type = command_options.source_type || ""
      destination_type = command_options.destination_type || ""
      service.create_shard(ShardInfo.new(shard_id = ShardId.new(host, table), class_name, source_type, destination_type, busy))
      service.get_shard(shard_id)
      puts shard_id.to_unix
    end
  end

  class LinksCommand < Command
    def run
      shard_ids = @argv
      shard_ids.each do |shard_id_text|
        shard_id = ShardId.parse(shard_id_text)
        service.list_upward_links(shard_id).each do |link_info|
          puts link_info.to_unix
        end
        service.list_downward_links(shard_id).each do |link_info|
          puts link_info.to_unix
        end
      end
    end
  end

  class InfoCommand < Command
    def run
      shard_ids = @argv
      shard_ids.each do |shard_id|
        shard_info = service.get_shard(ShardId.parse(shard_id))
        puts shard_info.to_unix
      end
    end
  end

  class WrapCommand < Command
    def self.derive_wrapper_shard_id(shard_info, wrapping_class_name)
      prefix_prefix = wrapping_class_name.split(".").last.downcase.gsub("shard", "") + "_"
      ShardId.new("localhost", prefix_prefix + shard_info.id.table_prefix)
    end

    def run
      class_name, *shard_ids = @argv
      help! "No shards specified" if shard_ids.empty?
      shard_ids.each do |shard_id_string|
        shard_id   = ShardId.parse(shard_id_string)
        shard_info = service.get_shard(shard_id)
        service.create_shard(ShardInfo.new(wrapper_id = self.class.derive_wrapper_shard_id(shard_info, class_name), class_name, "", "", 0))

        existing_links = service.list_upward_links(shard_id)
        unless existing_links.include?(LinkInfo.new(wrapper_id, shard_id, 1))
          service.add_link(wrapper_id, shard_id, 1)
          existing_links.each do |link_info|
            service.add_link(link_info.up_id, wrapper_id, link_info.weight)
            service.remove_link(link_info.up_id, link_info.down_id)
          end
        end
        puts wrapper_id.to_unix
      end
    end
  end

  class FindCommand < Command
    def run
      help!("host is a required option") unless command_options.shard_host
      service.shards_for_hostname(command_options.shard_host).each do |shard|
        next if command_options.shard_type && shard.class_name !~ Regexp.new(command_options.shard_type)
        puts shard.id.to_unix
      end
    end
  end
end