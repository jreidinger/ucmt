require "yaml"
require "cheetah"
require "fileutils"

module UCMT
  class Salt
    def initialize(data)
      @data = data
    end

    def write(output_dir)
      FileUtils.mkdir_p(output_dir)
      write_local_users(output_dir)
    end

  private

    USERS_MAPPING = {
      "fullname" => "fullname",
      "name" => "name",
      "uid" => "uid",
      "groups" => "groups",
      "primary_group" => "gid",
      "shell" => "shell",
      "home" => "home",
      "password" => "password"
    }
    def write_local_users(output_dir)
      result = {}

      puts @data.inspect
      users_data = @data["local_users"]
      return unless users_data

      (users_data["add"] || []).each do |user|
        key = user["name"]
        key2 = "user.present"
        result[key] = { key2 => [] }
        target = result[key][key2]
        USERS_MAPPING.each_pair do |k, v|
          target << { v => user[k] } if user[k]
        end
      end

      (users_data["remove"] || []).each do |user|
        key = "remove " + user["name"]
        key2 = "user.absent"
        result[key] = { key2 => [{"name" => user["name"]}] }
      end

      File.write(File.join(output_dir, "local_users.sls"), result.to_yaml)
    end
  end
end
