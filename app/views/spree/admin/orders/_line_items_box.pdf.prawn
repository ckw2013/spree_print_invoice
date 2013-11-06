# Address Stuff

bill_address = @order.bill_address
ship_address = @order.ship_address
anonymous = @order.email =~ /@example.net$/


bounding_box [0,600], :width => 540 do
  move_down 2
  data = [[Prawn::Table::Cell.new( :text => Spree.t(:billing_address), :font_style => :bold ),
                Prawn::Table::Cell.new( :text => Spree.t(:shipping_address), :font_style => :bold )]]

  table data,
    :position => :center,
    :border_width => 0.5,
    :vertical_padding => 2,
    :horizontal_padding => 6,
    :font_size => 9,
    :border_style => :underline_header,
    :column_widths => { 0 => 270, 1 => 270 }

  move_down 2
  horizontal_rule

  bounding_box [0,0], :width => 540 do
    move_down 2
    if anonymous and Spree::Config[:suppress_anonymous_address]
      data2 = [[" "," "]] * 6
    else
      data2 = [["#{bill_address.firstname} #{bill_address.lastname}", "#{ship_address.firstname} #{ship_address.lastname}"],
            [bill_address.address1, ship_address.address1]]
      data2 << [bill_address.address2, ship_address.address2] unless
                bill_address.address2.blank? and ship_address.address2.blank?
      data2 << ["#{@order.bill_address.zipcode} #{@order.bill_address.city} #{(@order.bill_address.state ? @order.bill_address.state.abbr : "")} ",
                  "#{@order.ship_address.zipcode} #{@order.ship_address.city} #{(@order.ship_address.state ? @order.ship_address.state.abbr : "")}"]
      data2 << [bill_address.country.name, ship_address.country.name]
      data2 << [bill_address.phone, ship_address.phone]
      shipping_method_name = @order.shipments.map{|sh| sh.shipping_method.try(:name)}.compact.uniq.join(', ')
      data2 << [shipping_method_name, shipping_method_name]
    end

    table data2,
      :position => :center,
      :border_width => 0.0,
      :vertical_padding => 0,
      :horizontal_padding => 6,
      :font_size => 9,
      :column_widths => { 0 => 270, 1 => 270 }
  end

  move_down 2

  stroke do
    line_width 0.5
    line bounds.top_left, bounds.top_right
    line bounds.top_left, bounds.bottom_left
    line bounds.top_right, bounds.bottom_right
    line bounds.bottom_left, bounds.bottom_right
  end

end

move_down 10

#Line Item Stuff

if @hide_prices
  @column_widths = { 0 => 100, 1 => 165, 2 => 75, 3 => 75 }
  @align = { 0 => :left, 1 => :left, 2 => :right, 3 => :right }
else
  @column_widths = { 0 => 75, 1 => 205, 2 => 75, 3 => 50, 4 => 75, 5 => 60 }
  @align = { 0 => :left, 1 => :left, 2 => :left, 3 => :right, 4 => :right, 5 => :right}
end

# Line Items
bounding_box [0,cursor], :width => 540, :height => 430 do
  move_down 2
  header =  [Prawn::Table::Cell.new( :text => Spree.t(:sku), :font_style => :bold),
                Prawn::Table::Cell.new( :text => Spree.t(:item_description), :font_style => :bold ) ]
  header <<  Prawn::Table::Cell.new( :text => Spree.t(:options), :font_style => :bold )
  header <<  Prawn::Table::Cell.new( :text => Spree.t(:price), :font_style => :bold ) unless @hide_prices
  header <<  Prawn::Table::Cell.new( :text => Spree.t(:qty), :font_style => :bold, :align => 1 )
  header <<  Prawn::Table::Cell.new( :text => Spree.t(:total), :font_style => :bold ) unless @hide_prices

  table [header],
    :position           => :center,
    :border_width => 1,
    :vertical_padding   => 2,
    :horizontal_padding => 6,
    :font_size => 9,
    :column_widths => @column_widths ,
    :align => @align

  move_down 4

  bounding_box [0,cursor], :width => 540 do
    move_down 2
    content = []
    @order.line_items.each do |item|
      row = [ item.variant.product.sku, item.variant.product.name]
      row << item.variant.option_values.map {|ov| "#{ov.option_type.presentation}: #{ov.presentation}"}.concat(item.respond_to?('ad_hoc_option_values') ? item.ad_hoc_option_values.map {|pov| "#{pov.option_value.option_type.presentation}: #{pov.option_value.presentation}"} : []).join(', ')
      row << number_to_currency(item.price) unless @hide_prices
      row << item.quantity
      row << number_to_currency(item.price * item.quantity) unless @hide_prices
      content << row
    end


    table content,
      :position           => :center,
      :border_width => 0.5,
      :vertical_padding   => 5,
      :horizontal_padding => 6,
      :font_size => 9,
      :column_widths => @column_widths ,
      :align => @align
  end

  font "Helvetica", :size => 9

  bounding_box [20,cursor  ], :width => 400 do
    render :partial => "bye" unless @hide_prices
  end

  render :partial => "totals" unless @hide_prices

  move_down 2

  stroke do
    line_width 0.5
    line bounds.top_left, bounds.top_right
    line bounds.top_left, bounds.bottom_left
    line bounds.top_right, bounds.bottom_right
    line bounds.bottom_left, bounds.bottom_right
  end

end
