--Production Output, Production Input, Production Output Scrap, Production Input scrap, Machine
--Sales 

--This is the Finished Good production run, detail, No lots
--Use the Max_lot_completed_date as THE date when the production was finished
select rpr.production_run_id, rpr.run_date, rpr.collected_from_sheet_name, rpr.db_created_at 
	, timezone('America/New_York',rpro.max_lot_completed_timestamp) as Actual_Run_Date_America_New_York
	, rpro.max_lot_completed_timestamp as Actual_Run_Date
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
				--where production_run_id = 11399
				group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , production_run_id , pe.cat3desc 
		)rpro on rpr.production_run_id  = rpro.output_production_run_id 
	--where rpr.production_run_id  = 20607
	--where rpr.run_date = '2023-05-05'
		where rpro.lot_machine_name = 'mespack01'
		and run_date > '2023-05-01' 
	order by rpr.production_run_id 





--This is the Component production run,detail, no lots
select rpr.production_run_id, rpr.run_date, rpr.collected_from_sheet_name 
	,pli2.production_input_id, pi2.input_sku , pi2.input_type , pi2.input_quantity_scrapped , pi2.input_quantity_matched 
	,sum(pli2.input_quantity_used) sum_input_qty_used 
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join cirkul_warehouse_logs.raw_production_run_outputs rpro on rpr.production_run_id  = rpro.production_run_id 
	left join cirkul_warehouse_logs.production_lots pl on pl.lot_code = rpro.lot_code 
	left join cirkul_warehouse_logs.production_lot_inputs pli2 on pli2.production_lot_id = pl.production_lot_id  
	left join cirkul_warehouse_logs.production_inputs pi2 on pi2.production_input_id = pli2.production_input_id 
	where rpr.production_run_id  = 11399
	--where rpro.output_sku  = 'FCS'
	--and rpr.run_date  = '2023-04-06'
	--and pi2.input_sku = 'FC'
	group by rpr.production_run_id, rpr.run_date, rpr.collected_from_sheet_name 
	,pli2.production_input_id, pi2.input_sku , pi2.input_type , pi2.input_quantity_scrapped , pi2.input_quantity_matched 
--	having sum(pli2.input_quantity_used) <> pi2.input_quantity_matched
	limit 1000;

--This is the Finished Good production Summary by day

select count(*) from 
(
select rpr.run_date
	,rpr.production_run_id
	, rpro.output_sku , rpro.output_type , rpro.lot_machine_code , rpro.lot_machine_name, 
	sum(sum_qty_kept) Sum_Qty_Kept, sum(sum_qty_scrap) Sum_Qty_Scrap
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join 
		(
			select production_run_id , output_sku , output_type , lot_machine_name , lot_machine_code   
				,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap 
				from cirkul_warehouse_logs.raw_production_run_outputs rpro 
				group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name, production_run_id 
		)rpro on rpr.production_run_id  = rpro.production_run_id 
	--where rpr.production_run_id  = 11399
	where rpr.run_date = '2023-04-06'
	group by rpr.run_date , rpro.output_sku , rpro.output_type , rpro.lot_machine_code , rpro.lot_machine_name
	,rpr.production_run_id
	order by rpro.output_sku  
) a;

--This is the Component production Summary by day
select rpr.run_date, rpro.output_sku  
	,pi2.input_sku , pi2.input_type 
	, sum(pi2.input_quantity_scrapped) Sum_Qty_Scrapped  
	,sum(pli2.input_quantity_used) sum_input_qty_used 
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join cirkul_warehouse_logs.raw_production_run_outputs rpro on rpr.production_run_id  = rpro.production_run_id 
	left join cirkul_warehouse_logs.production_lots pl on pl.lot_code = rpro.lot_code 
	left join cirkul_warehouse_logs.production_lot_inputs pli2 on pli2.production_lot_id = pl.production_lot_id  
	left join cirkul_warehouse_logs.production_inputs pi2 on pi2.production_input_id = pli2.production_input_id 
	where rpr.run_date = '2023-04-06'
	and pi2.input_sku  is not null
	group by rpr.run_date , pi2.input_sku , pi2.input_type , rpro.output_sku 
	order by rpro.output_sku 
	

--WORKING ON THIS ONE: This is labor by production order	
	select rpr.production_run_id, rpr.run_date, rpr.collected_from_sheet_name 
		, rpro.* 
		from cirkul_warehouse_logs.raw_production_runs rpr  
		left join 
			(
				select production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
					, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name  
					,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap 
					from cirkul_warehouse_logs.raw_production_run_outputs rpro 
					group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
					, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name, production_run_id 
			)rpro on rpr.production_run_id  = rpro.production_run_id 
		where rpr.production_run_id  = 11399
		--where rpr.run_date = '2023-04-06'
		order by rpr.production_run_id 
		limit 1000;

	select * from cirkul_warehouse_logs.raw_production_runs rpr where production_run_id  = 11399;
	select * from cirkul_warehouse_logs.raw_production_run_outputs rpro limit 100	
	
--This is labor by output_sku by day	
	

	
	
	select count(*) from cirkul_warehouse_logs.production_lots pl 
	
	
--BELOW ARE DISCOVERY QUERIES TO FIGURE OUT RELATIONSHIPS	
--Production run line Input data tie out to tables
	select * from cirkul_warehouse_logs.raw_production_runs rpr where is_from_webapp = true 
	
	
	select * from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id  = 20607;
	select * from cirkul_warehouse_logs.production_lots pl  where lot_code in (select lot_code from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id  = 20607)
		order by lot_code;
	select * from cirkul_warehouse_logs.production_lot_inputs pli2 where production_lot_id  in
		( 
			select production_lot_id  from cirkul_warehouse_logs.production_lots pl  where lot_code in (select lot_code from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id  = 20607)
				order by lot_code
		) order by production_lot_id;
--	select * from cirkul_warehouse_logs.production_lot_inputs pli2 where production_input_id = 2641281  limit 100;
	select * from cirkul_warehouse_logs.production_inputs pi2 where production_input_id = 2914208 limit 100

--Production Output
	select output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
		, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name  
		,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap 
		from cirkul_warehouse_logs.raw_production_run_outputs rpro 
--		where production_run_id  = 11399
		group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
		, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name;

	--Production Input
	select output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
		, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name  
		,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap 
		from cirkul_warehouse_logs.raw_production_run_outputs rpro 
		where production_run_id  = 11399
		group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
		, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name;

	
--	'R_FS_FITMB-100-001-076-09623-17-01' limit 100;
	--2025988
	
--Production run line input data 
--select * from cirkul_warehouse_logs.raw_production_run_inputs rpri  where production_run_id  = 11399 limit 100;
--select * from cirkul_warehouse_logs.production_lots pl where lot_code = 'NDS-10800-002-003-09423-01-04' limit 100
select * from cirkul_warehouse_logs.production_inputs pli where input_lot_code like 'NDS-10800-002-003%' 
and db_created_at  > '2023-04-01'
limit 100;


'NDS-10800-002-003-09423-01-04'


--Production Lot Code Output ties to production run above, Production_lots table has only outputs
	select * from cirkul_warehouse_logs.production_lots pl where lot_code = 'R_FS_FITMB-100-001-076-09623-17-01' limit 100
	
--Production Lot Code Input ties to production run above
	select * from cirkul_warehouse_logs.production_lots pl where lot_code = 'NDS-10800-002-003-09423-01-04' limit 100
	
select * from cirkul_warehouse_logs.production_inputs pi2 limit 100;
select * from cirkul_warehouse_logs.production_lot_inputs pli limit 100;





'R_FS_FITMB-100-001-076-09623-17-01'


	
