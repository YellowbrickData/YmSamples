-- Number of patients who were vaccinated for Polio.

select count(*) as num_patients from healthcare.immunizations where code='10';

