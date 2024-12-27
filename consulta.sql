with batimetria_filtrada as (
	select ST_SetSRID(geom, 4326) as geom, "depth"
	from public.cabos_med_batimetria
	where "depth" = 4000),
cabos_filtrados as (
	select id, "name", ST_SetSRID(geom, 4326) as geom
	from public.cabos_med_cableemodnet
	where "name" is not null and TRIM("name") <> '' )
select c.id, c."name" as cabo_nome, COUNT(b."time") as quantidade_terremotos, cb."depth" as batimetria, ST_AsText(ST_ClosestPoint(cb.geom, c.geom)) as ponto_na_batimetria
from
	( select *, ST_SetSRID(geom, 4326) as geom_t
	from public.bd2_leonardo_bochnia) b
join cabos_filtrados c  
	on ST_DWithin(b.geom_t::geography, c.geom::geography, 50000, true)
join batimetria_filtrada cb 
    on ST_Intersects(c.geom, cb.geom)
where b.mag >= 5
group by c.id, c."name", cb."depth", cb.geom, c.geom;
