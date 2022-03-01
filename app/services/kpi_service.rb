class KpiService
  class << self
    def gather_kpis
      kpi_rows = []

      kpi_rows << gather_kpis_for('User')
      kpi_rows << gather_kpis_for('Story')
      kpi_rows << gather_kpis_for('Invitation')
      kpi_rows << gather_kpis_for('Family')
      kpi_rows << gather_kpis_for('Appreciation')
    end

    def gather_kpis_for(class_name)
      model = class_name.constantize
      [
        class_name.pluralize.to_s,
        model.where('created_at > ?', 1.week.ago).count.to_s,
        model.where('created_at > ?', 1.month.ago).count.to_s,
        model.count.to_s
      ]
    end
  end
end
