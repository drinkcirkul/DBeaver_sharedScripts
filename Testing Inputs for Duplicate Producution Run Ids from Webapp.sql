select distinct production_run_id, output_sku, output_type, count(*)
from 
(
--This is the Component production INPUT, detail, no lots
select 
	rpro.production_run_id
 	, rpro.output_sku 
	, rpro.output_type 
--	, pi2.input_sku 
--	, pi2.input_type 
--	, pi2.input_quantity_scrapped 
	,sum(pli2.input_quantity_used) sum_input_qty_used 
	
	from cirkul_warehouse_logs.raw_production_run_outputs rpro  
		left join cirkul_warehouse_logs.production_lots pl on pl.lot_code = rpro.lot_code 
		left join cirkul_warehouse_logs.production_lot_inputs pli2 on pli2.production_lot_id = pl.production_lot_id  
		left join cirkul_warehouse_logs.production_inputs pi2 on pi2.production_input_id = pli2.production_input_id 
			left join cirkul_warehouse_logs.raw_production_runs rpr on rpr.production_run_id  = rpro.production_run_id 
	
	where rpr.is_from_webapp = true
--		and rpro.production_run_id  = 20607
	--where rpro.output_sku  = 'FCS'
	--and rpr.run_date  = '2023-04-06'
	--and pi2.input_sku = 'FC'
	
	
	group by
	rpro.production_run_id
 	, rpro.output_sku 
	, rpro.output_type 
--	, pi2.input_sku 
--	, pi2.input_type 
--	, pi2.input_quantity_scrapped 
	
--	having sum(pli2.input_quantity_used) <> pi2.input_quantity_matched
) a	
group by production_run_id, output_sku, output_type
having count(*) > 1