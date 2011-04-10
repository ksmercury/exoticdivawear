class DivalifeHooks < Spree::ThemeSupport::HookListener
  # custom hooks go here
  
  #insert_before :homepage_products, :text => "<h1>Exotic Diva Wear</h1>"
  insert_before :homepage_products, 'shared/kim_image'
   insert_before   :homepage_sidebar_navigation,  :text => "<h1>Give</h1>"
   insert_before   :product_description,  :text => "<h1>Here</h1>"
   insert_before   :sidebar,  :text => "<h1>Yes</h1>"
   insert_before   :inside_head,  :text => "<h1>Here</h1>"
   

  
 
  
end