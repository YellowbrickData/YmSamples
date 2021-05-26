-- Number of facemasks used by each medical facility.

select organizations.org_name, sum(supplies.quantity) as num_facemasks
from healthcare.supplies supplies
inner join healthcare.encounters as encounters on (encounters.id = supplies.encounter)
inner join healthcare.organizations as organizations on (encounters.organization = organizations.id)
where supplies.code = '706724001'
group by organizations.org_name
order by num_facemasks desc 
limit 100;

