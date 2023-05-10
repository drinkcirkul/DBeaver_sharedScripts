--1. Why only data back to February?
--1. Change of FG Item during production run.  This looks like a floor process error.  Correct in Web App?
select rpr.production_run_id, rpr.run_date, rpr.collected_from_sheet_name
	, rpro.*
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join 
		(
			select production_run_id as output_production_run_id, output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc Shift
				,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap
				,min(lot_code) Min_Lot_Code
				,max(lot_code) Max_Lot_Code
				,min(lot_completed_timestamp) min_lot_completed_timestamp
				,max(lot_completed_timestamp) max_lot_completed_timestamp
				from cirkul_warehouse_logs.raw_production_run_outputs rpro 
				left join cirkul_warehouse.paycom_employees pe on pe.eecode = lot_operator_1_code 
				group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , production_run_id , pe.cat3desc 
		)rpro on rpr.production_run_id  = rpro.output_production_run_id 
	where rpr.run_date >= '2023-04-01'
	and rpr.production_run_id in (11255)
;
--2. Missing output_type on the run, splits the run in two
select rpr.production_run_id, rpr.run_date, rpr.collected_from_sheet_name
	, rpro.*
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join 
		(
			select production_run_id as output_production_run_id, output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc Shift
				,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap
				,min(lot_code) Min_Lot_Code
				,max(lot_code) Max_Lot_Code
				,min(lot_completed_timestamp) min_lot_completed_timestamp
				,max(lot_completed_timestamp) max_lot_completed_timestamp
				from cirkul_warehouse_logs.raw_production_run_outputs rpro 
				left join cirkul_warehouse.paycom_employees pe on pe.eecode = lot_operator_1_code 
				group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , production_run_id , pe.cat3desc 
		)rpro on rpr.production_run_id  = rpro.output_production_run_id 
	where rpr.run_date >= '2023-04-01'
	and rpr.production_run_id in (11058)
;
