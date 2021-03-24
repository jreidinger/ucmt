require "yaml"
require "cheetah"
require "fileutils"

module UCMT
  class Ansible
    def initialize(output_dir)
      @output_dir = output_dir
    end

    def write(data)
      FileUtils.mkdir_p(@output_dir)

      result = local_users_content(data)

      content = [{
        "name" => "UCMT defined tasks",
        "hosts" => "localhost",
        "connection" => "local",
        "tasks" => result
      }]

      File.write(File.join(@output_dir, "states.yml"), content.to_yaml)
    end

    def dry_run
      Cheetah.run("ansible-playbook", File.join(@output_dir, "states.yml"), "--check", "--diff", stdout: STDOUT)
    end

    def apply
      Cheetah.run("ansible-playbook", File.join(@output_dir, "states.yml"), stdout: STDOUT)
    end

  private

    USERS_MAPPING = {
      "fullname" => "comment",
      "name" => "name",
      "uid" => "uid",
      "groups" => "groups",
      "primary_group" => "group",
      "shell" => "shell",
      "home" => "home",
      "password" => "password"
    }
    def local_users_content(data)
      result = []

      users_data = data["local_users"]
      return [] unless users_data

      (users_data["add"] || []).each do |user|
        res = { "name" => "User #{user["name"]}" }
        key2 = "ansible.builtin.user"
        res[key2] = {}
        USERS_MAPPING.each_pair do |k, v|
          res[key2][v] = user[k] if user[k]
        end

        result << res
      end

      (users_data["remove"] || []).each do |user|
        res = { "name" => "remove " + user["name"] }
        key2 = "ansible.builtin.user"
        res[key2] = { "name" => user["name"],
          "state" => "absent", "remove" => "yes" }

        result << res
      end

      result
    end
  end
end

