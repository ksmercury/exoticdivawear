module ProductFilters
 Product.scope :price_range_any,
 lambda {|*opts|      
 conds = opts.map {|o| ProductFilters.price_filter[:conds][o]}.reject {|c| c.nil?}      
 Product.scoped(:joins => :master).conditions_any(conds)    
 }  
 def ProductFilters.price_filter    
 conds = [ [ "Under $10",    "price             <= 10" ],
 [ "$10 - $15",    "price between 10 and 15" ],
 [ "$15 - $18",    "price between 15 and 18" ],
 [ "$18 - $20",    "price between 18 and 20" ],              
 [ "$20 or over",  "price             >= 20" ] ]    
 { :name   => "Price Range",      
 :scope  => :price_range_any,      
 :conds  => Hash[*conds.flatten],      
 :labels => conds.map {|k,v| [k,k]}    
 }  
 end
 
 if Property.table_exists? && @@brand_property = Property.find_by_name("brand")
 Product.scope :brand_any,      
 lambda {|*opts|        
 conds = opts.map {|o| ProductFilters.brand_filter[:conds][o]}.reject {|c| c.nil?}        
 Product.with_property("brand").conditions_any(conds)     
 }    
 def ProductFilters.brand_filter      
 brands = ProductProperty.find_all_by_property_id(@@brand_property).map(&:value).uniq      
 conds  = Hash[*brands.map {|b| [b, "product_properties.value = '#{b}'"]}.flatten]      
 { :name   => "Brands",       
 :scope  => :brand_any,        
 :conds  => conds,        
 :labels => (brands.sort).map {|k| [k,k]}     
 }   
 end 
 end
 
 if Property.table_exists? && @@brand_property    
 Product.scope :selective_brand_any, lambda {|opts| Product.brand_any(opts) }    
 def ProductFilters.selective_brand_filter(taxon = nil)      
 if taxon.nil?       
 taxon = Taxonomy.first.root      
 end     
 all_brands = ProductProperty.find_all_by_property_id(@@brand_property).map(&:value).uniq    
 scope = ProductProperty.scoped(:conditions => ["property_id = ?", @@brand_property]).                              
 scoped(:joins      => {:product => :taxons},                                     
 :conditions => ["taxons.id in (?)", [taxon] + taxon.descendants])      
 brands = scope.map {|p| p.value}      
 { :name   => "Applicable Brands",        
 :scope  => :selective_brand_any,        
 :conds  => Hash[*all_brands.map {|m| [m, "p_colour.value like '%#{m}%'"]}.flatten],        
 :labels => brands.sort.map {|k| [k,k]}      
 }   
 end  
 end
 
 def ProductFilters.taxons_below(taxon)   
 return ProductFilters.all_taxons if taxon.nil?   
 { :name   => "Taxons under " + taxon.name,      
 :scope  => :taxons_id_in_tree_any,      
 :labels => taxon.children.sort_by(&:position).map {|t| [t.name, t.id]},      
 :conds  => nil    
 }  
 end  
 # Filtering by the list of all taxons
 # 
 # Similar idea as above, but we don't want the descendants' products, hence
 # it uses one of the auto-generated scopes from SearchLogic.
 #  
 # idea: expand the format to allow nesting of labels?  
 def ProductFilters.all_taxons    
 taxons = Taxonomy.all.map {|t| [t.root] + t.root.descendants }.flatten    
 { :name   => "All taxons",      
 :scope  => :taxons_id_equals_any,      
 :labels => taxons.sort_by(&:name).map {|t| [t.name, t.id]},      
 :conds  => nil	# not needed    
 }  
 end
 end