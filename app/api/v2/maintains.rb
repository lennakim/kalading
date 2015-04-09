module V2
  class Maintains < Grape::API
    helpers SharedParams

    params do
      requires :auto_submodel_id
    end
    get "auto_maintain_order/:auto_submodel_id" do
      asm = AutoSubmodel.find(params[:auto_submodel_id])
      raise ResourceNotFoundError unless asm
      st = ServiceType.find_by name: I18n.t(:auto_maintain_service_type_name)
      raise ResourceNotFoundError unless st

      order = Order.new
      order.auto_submodel = asm
      order.service_types << st

      asm.parts_by_type_ignore_quantity.each do |t, parts|
        if t.name == I18n.t(:engine_oil)
          parts.group_by(&:spec)[parts.first.spec].each do |p|
            order.parts << p
            order.part_counts[p.id.to_s] = asm.cals_part_count(p)
          end
        elsif t.name == I18n.t(:cabin_filter)
          part = parts.find {|p| p.part_brand.name == I18n.t(:Kalading) } || parts.first
          order.parts << part
          order.part_counts[part.id.to_s] = asm.cals_part_count(part)
        else
          order.parts << parts.first
          order.part_counts[parts.first.id.to_s] = asm.cals_part_count(parts.first)
        end
      end

      wrapper(asm.parts_by_type_ignore_quantity)
    end

  end
end
