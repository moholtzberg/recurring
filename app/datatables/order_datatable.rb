class OrderDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :dropdown, :number_to_currency, :expand_button

  def view_columns
    @view_columns ||= {
      number: { source: "Order.number" },
      account: { source: "Account.name" },
      total: { source: "", searchable: false },
      sub_total: { source: "Order.sub_total", cond: :eq },
      shipped: { source: "", searchable: false },
      fulfilled: { source: "", searchable: false },
      balance_due: { source: "", searchable: false },
      submitted_at: { source: "Order.submitted_at" },
      state: { source: "Order.state", cond: :eq },
      dropdown: { source: "", searchable: false }
    }
  end

  def data
    records.map do |record|
      {
        number: expand_button(record.class, record),
        account: record.account&.name,
        total: number_to_currency(record.total),
        sub_total: number_to_currency(record.sub_total),
        shipped: number_to_currency(record.amount_shipped),
        fulfilled: number_to_currency(record.amount_fulfilled),
        balance_due: number_to_currency(record.balance_due),
        submitted_at: record.submitted_at&.strftime("%m/%d/%y %I:%M %p"),
        state: record.state,
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    orders = Order.eager_load({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment])
    orders.where(filter_query(options[:filters]))
  end

  def filter_query(filters)
    query = []
    filters.to_a.each do |_, f|
      source = view_columns[f['column_name'].to_sym][:source]
      if source.include?('.')
        model = source.split('.').first.constantize
        table = model.arel_table rescue model
        field = source.split('.').last.to_sym
        source = "#{table.name}.#{field}"
      end
      source = source + "::date" if f['column_name'] == 'submitted_at'
      query.push case f['filter']
                 when 'Equal to'
                   "#{source} = '#{f['value']}'"
                 when 'Contains'
                   "#{source} like '%#{f['value']}%'"
                 when 'Begins with'
                   "#{source} like '#{f['value']}%'"
                 when 'Ends with'
                   "#{source} like '#{f['value']}%'"
                 when 'Not equal to'
                   "#{source} <> '#{f['value']}'"
                 when 'Greater than'
                   "#{source} > '#{f['value']}'"
                 when 'Less than'
                   "#{source} < '#{f['value']}'"
                 end
    end
    query.join(' AND ')
  end
end
