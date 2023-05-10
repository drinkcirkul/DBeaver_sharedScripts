--Akshay report Data in SQL

--Finished Good Production by Production Run, by Day, By Operator, By FG Item, By Machine, By Lot
--select count(*), a.production_run_id, a.run_date  
--from 
--(

select rpr.production_run_id||rpro.output_sku||rpro.output_type production_run_id, rpr.run_date, rpr.collected_from_sheet_name
--select rpr.production_run_id||rpro.output_sku production_run_id , rpr.run_date, rpr.collected_from_sheet_name
--select rpr.production_run_id  , rpr.run_date, rpr.collected_from_sheet_name
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
	where rpr.run_date >= '2023-04-01'
	--and rpr.production_run_id in (11058,10859,13536,13420)
	--and rpr.production_run_id in (13536)

--) a
--group by a.production_run_id , a.run_date
--having count(*) > 1
;	

	--Component Production by Production Run, by Day, By Operator, By FG Item, By Machine, By Lot
--select rpr.production_run_id||rpro.output_sku||rpro.output_type production_run_id
--CSP example: Should input item be a CSP?
select rpr.production_run_id
	,pi2.input_sku , pi2.input_type, pi2.input_lot_code
	,sum(pli2.input_quantity_used) Sum_input_quantity_used
	, sum(pi2.input_quantity_scrapped) Sum_input_qty_scrapped  
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join 
	(			select production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc Shift
				,lot_code
				,max(lot_date) max_lot_date
				,max(lot_completed_timestamp) max_lot_completed_timestamp 
				,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap
				from cirkul_warehouse_logs.raw_production_run_outputs rpro 
				left join cirkul_warehouse.paycom_employees pe on pe.eecode = lot_operator_1_code 
				group by production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc 
				,lot_code
	) rpro	
	on rpr.production_run_id  = rpro.production_run_id --Flatten this to one line per lot code
	left join cirkul_warehouse_logs.production_lots pl on pl.lot_code = rpro.lot_code 
	left join cirkul_warehouse_logs.production_lot_inputs pli2 on pli2.production_lot_id = pl.production_lot_id  
	left join cirkul_warehouse_logs.production_inputs pi2 on pi2.production_input_id = pli2.production_input_id 
	where rpr.run_date >= '2023-04-01'
	and rpr.production_run_id  = 7148
	group by rpr.production_run_id
	,pi2.input_sku , pi2.input_type, pi2.input_lot_code  
	,pi2.input_sku , pi2.input_type, pi2.input_lot_code 

;

--group by rpr.production_run_id||rpro.output_sku||rpro.output_type  
	
--Query to get the columns for OEE
select 
	--rpr.run_date
	rpro.max_lot_completed_timestamp run_date 
	, rpro.lot_machine_name , rpro.lot_machine_code
	, coalesce(rpro.Shift,'A') Shift
	, sum(rpro.sum_qty_kept) Quantity_produced
	from cirkul_warehouse_logs.raw_production_runs rpr  
	left join 
		(
			select production_run_id as output_production_run_id, output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc Shift
				,max(lot_completed_timestamp) - min(lot_completed_timestamp) as time_spent
				,sum(output_quantity_kept) sum_qty_kept
				,sum(output_quantity_scrapped) as sum_qty_scrap
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
	--where rpr.production_run_id  = 11255
	where rpr.run_date >= '2023-04-01'
group by rpro.max_lot_completed_timestamp 
	, rpro.lot_machine_name , rpro.lot_machine_code
	, rpro.Shift
	
	
/*
--Discovery queries

	--Production run line Input data tie out to tables
			select production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc Shift
				,lot_code
				,max(lot_date) max_lot_date
				,max(lot_completed_timestamp) max_lot_completed_timestamp 
				,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap
				from cirkul_warehouse_logs.raw_production_run_outputs rpro 
				left join cirkul_warehouse.paycom_employees pe on pe.eecode = lot_operator_1_code 
				where production_run_id = 7148
				group by production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc 
				,lot_code
			
				
select * from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id  = 7148;
select * from cirkul_warehouse_logs.raw_production_run_outputs rpro where lot_code  like 'FLFITILPNCH-274-001-026%'
select * from cirkul_warehouse_logs.production_lots pl2 

	select * from cirkul_warehouse_logs.production_lots pl  where lot_code in (select lot_code from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id  = 7148)
		order by lot_code;
	select * from cirkul_warehouse_logs.production_lot_inputs pli2 where production_lot_id  in
		( 
			select production_lot_id  from cirkul_warehouse_logs.production_lots pl  where lot_code in (select lot_code from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id  = 7148)
				order by lot_code
		) order by production_lot_id;
	select * from cirkul_warehouse_logs.production_lot_inputs pli2 where production_input_id = 2641281  limit 100;
	select * from cirkul_warehouse_logs.production_inputs pi2 where production_input_id = 2641281 limit 100

	select * from cirkul_warehouse_logs.raw_production_run_inputs rpri where production_run_id  = 7148 limit 1000
	FLFITILPNCH-274-001-026-12323-13-01

		
	select * from cirkul_warehouse_logs.raw_production_runs rpr where rpr.run_date > '2023-04-25' 
	select * from cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id = 18560
	
SELECT timezone(lot_completed_timestamp , 'UTC', 'America/New_York') AS est_datetime


select lot_completed_timestamp at time zone 'pdt' as NewA, *
FROM cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id = 18560;

SELECT timezone('EST',lot_completed_timestamp) AS est_datetime
,timezone('PST',lot_completed_timestamp) AS est_datetime
,timezone('UTC',lot_completed_timestamp) AS est_datetime
,*
FROM cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id = 18560;

select timestamptz getdate()

	SELECT ((lot_completed_timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'EST') AS local_timestamp
	,*
	FROM cirkul_warehouse_logs.raw_production_run_outputs rpro where production_run_id = 18560;
	
			select production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , pe.cat3desc Shift
				,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap
				,min(lot_code) Min_Lot_Code
				,max(lot_code) Max_Lot_Code
				from cirkul_warehouse_logs.raw_production_run_outputs rpro 
				left join cirkul_warehouse.paycom_employees pe on pe.eecode = lot_operator_1_code 
				where production_run_id = 11399
				group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
				, lot_operator_1_code ,lot_operator_1_name , production_run_id , pe.cat3desc 


select * from cirkul_warehouse_logs.raw_production_runs rpr where production_run_id = 11399;
select * from cirkul_warehouse_logs.raw_production_run_outputs rpro2 where production_run_id = 11399;
select * from cirkul_warehouse_logs.production_lots pl  limit 1000
select * from cirkul_warehouse.paycom_employees pe where eecode = 'A28F'
*/
