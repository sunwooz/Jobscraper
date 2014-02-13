class AddVectorSearchToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :search_vector, :tsvector
    execute <<-SQL
      CREATE INDEX jobs_search_idx
      ON jobs
      USING gin(search_vector);
    SQL

    execute <<-SQL
      DROP TRIGGER IF EXISTS jobs_search_vector_update
      ON jobs;
      CREATE TRIGGER jobs_search_vector_update
      BEFORE INSERT OR UPDATE
      ON jobs
      FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger (search_vector, 'pg_catalog.english', content);
    SQL

    Job.find_each { |j| j.touch }
  end
end
