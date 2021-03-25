require "yaml"
require "cheetah"
require "fileutils"

module UCMT
  class Users
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def ignore(name)
      (users["add"] || []).delete_if { |u| u["name"] == name }
      (users["remove"] || []).delete_if { |u| u["name"] == name }
    end

    def remove(name)
      (users["add"] || []).delete_if { |u| u["name"] == name }
      users["remove"] ||= []
      users["remove"] << { "name" => name }
    end

    def edit(options)
      name = options[:name]

      # ensure that user is not removed
      (users["remove"] || []).delete_if { |u| u["name"] == name }
      users["add"] ||= []
      user = users["add"].find { |u| u["name"] == name }
      if !user
        user = { "name" => name }
        users["add"] << user
      end

      handle_option(:fullname, user, options)
      handle_option(:uid, user, options)
      handle_option(:primary_group, user, options)
      handle_option(:shell, user, options)
      handle_option(:home, user, options)

      # TODO: PASSWORD
      # TODO: groups
    end

    def list
      puts "Users to add/edit:"
      to_add = (users["add"] || []).map {|u| u["name"]}
      puts to_add.to_yaml unless to_add.empty?
      puts "\nUsers to remove:"
      to_remove = (users["remove"] || []).map {|u| u["name"]}
      puts to_remove.to_yaml unless to_remove.empty?
      puts
    end

    def show(name)
      remove = (users["remove"] || []).find { |u| u["name"] == name }
      if remove
        puts "User #{name} will be removed."
        return
      end
      add = (users["add"] || []).find { |u| u["name"] == name }
      if !add
        puts "User #{name} won't be modified."
        return
      end

      puts "User #{name} will have following settings:"
      puts add.to_yaml
    end

  private

    def handle_option(key, user, options)
      if options[:"no_#{key}"]
        user.delete(key.to_s)
      elsif options[key]
        user[key.to_s] = options[key]
      end
    end

    def users
      return @users if @users

      @data["local_users"] ||= {}
      @users = @data["local_users"]
    end
  end
end
