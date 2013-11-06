require 'prawn/layout'

font "Helvetica"
im = "#{Rails.root.to_s}/public/assets/logo.png"

image im , :at => [0,720] #, :scale => 0.35

fill_color "E99323"
if @hide_prices
  text Spree.t(:packaging_slip), :align => :right, :style => :bold, :size => 18
else
  text Spree.t(:customer_invoice), :align => :right, :style => :bold, :size => 18
end
fill_color "000000"

move_down 4

font "Helvetica",  :size => 9,  :style => :bold
text "#{Spree.t(:order_number)} #{@order.number}", :align => :right

move_down 2
font "Helvetica", :size => 9
text "#{I18n.l @order.completed_at.to_date}", :align => :right

render :partial => "address"

move_down 8

render :partial => "custom"

move_down 30

render :partial => "line_items_box"

move_down 8

# Footer
# render :partial => "footer"
