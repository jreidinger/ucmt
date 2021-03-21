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
        res = JSON.parse(`ansible localhost -m getent -a database=passwd`.sub(/^.*=>/, ""))
        res["ansible_facts"]["getent_passwd"]
      end

      def read_groups
        res = JSON.parse(`ansible localhost -m getent -a database=group`.sub(/^.*=>/, ""))
        res["ansible_facts"]["getent_group"]
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
        users = read_users.map do |dk, dv|
          USERS_KEYS_MAPPING.each_with_object({"name" => dk}) { |(k, v), r| r[k] = dv[v] }
        end
        users.each { |u| INTEGER_KEYS.each { |i| u[i] = u[i].to_i } }
        users.select! { |v| v["uid"] > SYSTEM_USER_LIMIT } # select only non system users
        users.each { |u| u["groups"] = [] }

        groups = read_groups
        groups.each do |name, group|
          gid = group[GROUPS_KEYS_MAPPING["gid"]].to_i
          group_users = group[GROUPS_KEYS_MAPPING["users"]].split(",") # see man group

          users.each do |user|
            if user["gid"] == gid || group_users.include?(user["name"])
              user["groups"] << name
            end
          end
        end

        users
      end
    end
  end
end
