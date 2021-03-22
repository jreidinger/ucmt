require "yaml"
require "cheetah"
require "fileutils"

module UCMT
  class Salt
    def initialize(output_dir)
      @output_dir = output_dir
    end

    def write(data)
      FileUtils.mkdir_p(@output_dir)

      states = []
      states << "local_users" if write_local_users(data)

      write_states(states)
    end

    def dry_run
      Cheetah.run("salt-call", "--local", "--file-root=#{@output_dir}", "state.apply", "test=true", stdout: STDOUT)
    end

  private

    def write_states(states)
      content = { "base" => { "*" => states } }

      File.write(File.join(@output_dir, "top.sls"), content.to_yaml)
    end

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
    def write_local_users(data)
      result = {}

      users_data = data["local_users"]
      return false unless users_data

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

      File.write(File.join(@output_dir, "local_users.sls"), result.to_yaml)

      return true
    end
  end
end
