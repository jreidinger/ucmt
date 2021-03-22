require "json"
require "cheetah"

module UCMT
  module Discovery
    class LocalUsers
      # TODO: remote machine
      def initialize
      end

      def read_data
        {
          "local_users" => {
            "add" => read
          }
        }
      end

    private

      def read_users
        output = Cheetah.run("ansible", "localhost", "-m", "getent", "-a", "database=passwd", stdout: :capture)

        res = JSON.parse(output.sub(/^.*=>/, ""))
        res["ansible_facts"]["getent_passwd"]
      end

      def read_groups
        output = Cheetah.run("ansible", "localhost", "-m", "getent", "-a", "database=group", stdout: :capture)

        res = JSON.parse(output.sub(/^.*=>/, ""))
        res["ansible_facts"]["getent_group"]
      end

      def read_passwords
        output = Cheetah.run("ansible", "localhost", "-m", "getent", "-a", "database=shadow", stdout: :capture)

        res = JSON.parse(output.sub(/^.*=>/, ""))
        res["ansible_facts"]["getent_shadow"]
      end

      USERS_KEYS_MAPPING = {
        "uid" => 1,
        "gid" => 2,
        "fullname" => 3,
        "home" => 4,
        "shell" => 5
      }
      INTEGER_KEYS = ["uid", "gid"]
      SYSTEM_USER_LIMIT = 500

      GROUPS_KEYS_MAPPING = {
        "gid" => 1,
        "users" => 2
      }

      def read
        # reading shadow need root permissions
        # TODO: for remote check needs to be different
        if Process.euid == 0
          passwd = read_passwords
        else
          passwd = {}
        end

        groups = read_groups

        users = read_users.map do |dk, dv|
          USERS_KEYS_MAPPING.each_with_object({"name" => dk}) { |(k, v), r| r[k] = dv[v] }
        end
        users.each { |u| INTEGER_KEYS.each { |i| u[i] = u[i].to_i } }
        users.select! { |v| v["uid"] == 0 || v["uid"] > SYSTEM_USER_LIMIT } # select only non system users
        users.each do |user|
          user["groups"] = []

          groups.each do |name, group|
            gid = group[GROUPS_KEYS_MAPPING["gid"]].to_i
            group_users = group[GROUPS_KEYS_MAPPING["users"]].split(",") # see man group

            if user["gid"] == gid || group_users.include?(user["name"])
              user["groups"] << name
            end
          end
          user["password"] = passwd[user["name"]].first if passwd[user["name"]]
        end

        users
      end
    end
  end
end
