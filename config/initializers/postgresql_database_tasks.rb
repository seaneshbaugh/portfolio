module ActiveRecord
  module Tasks
    class PostgreSQLDatabaseTasks
      # Monkey patch PostgreSQLDatabaseTasks#drop to avoid the following error:
      # PG::ObjectInUse: ERROR:  database "<database name>" is being accessed by other users
      def drop
        establish_master_connection

        connection.select_all "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname='#{configuration['database']}' AND state='idle';"

        connection.drop_database configuration['database']
      end
    end
  end
end
