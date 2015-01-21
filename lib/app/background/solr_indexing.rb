module App
  module Background
    class SolrIndexing
      @queue = :background_mailer
      def self.perform(model, model_id)
        row = model.constantize.find(model_id)
        row.index
      end
    end
  end
end