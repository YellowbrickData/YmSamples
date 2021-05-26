-- Patients who have had the most procedures.

select procedures.patient, patients.first_name, patients.last_name, patients.city, patients.state, count(*) as num_procedures 
from healthcare.procedures as procedures
inner join healthcare.patients as patients on (patients.id = procedures.patient)
group by procedures.patient, patients.first_name, patients.last_name, patients.city, patients.state
order by num_procedures desc limit 100;
