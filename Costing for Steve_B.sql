SELECT
	spvc.variant_sku AS storefront_sku,
	spvc.base_product_variant_sku AS fulfillment_sku,
	spvc.base_product_variant_title AS fulfillment_sku_variant, -- ie. color for bottles, size for shirts (N/A when the fulfillment SKU does not have variants, which is the case for sips)
	fsm.manufacturing_sku 
FROM shopify_product_variant_components spvc -- maps Storefront to Fulfillment
INNER JOIN business_intelligence.fulfillment_sku_metadata fsm -- maps Fulfillment to Manufacturing
	ON fsm.fulfillment_sku  = spvc.base_product_variant_sku 
	AND fsm.fulfillment_sku_variant_title  = spvc.base_product_variant_title 
WHERE fsm.manufacturing_sku  = 'LIFEBP'
--where fsm.fulfillment_sku <> 'N/A'
;

--select * from cirkul_warehouse.racetrack_runs rr;

--This one uses the variant SKU as the starting table, to catch all the variants
--To get the corresponding BC report, go to the Items List>>Reports>>Inventory>>Inventory Cost and price list
SELECT
	spv.variant_sku AS storefront_sku,
	spvc.base_product_variant_sku AS fulfillment_sku,
	spvc.base_product_variant_title AS fulfillment_sku_variant, -- ie. color for bottles, size for shirts (N/A when the fulfillment SKU does not have variants, which is the case for sips)
	fsm.manufacturing_sku 
FROM shopify_product_variants spv 
LEFT JOIN shopify_product_variant_components spvc on spv.variant_sku = spvc.variant_sku  -- maps Storefront to Fulfillment
LEFT JOIN business_intelligence.fulfillment_sku_metadata fsm -- maps Fulfillment to Manufacturing
	ON fsm.fulfillment_sku  = spvc.base_product_variant_sku 
	AND fsm.fulfillment_sku_variant_title  = spvc.base_product_variant_title 

	select * from shopify_product_variants spv;  
	select * from shopify_product_variant_components
	
	select * from shopify_customers sc limit 100
	select so.order_processed_at, * from fission.shopify_orders so order by so.order_processed_at desc limit 100
	select so.order_processed_at, * from stage_hydration.shopify_orders so order by so.order_processed_at desc limit 100
	
	