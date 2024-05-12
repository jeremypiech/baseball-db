with statcast as (
    select * from {{ ref('stg_statcast') }}
)

select *
from statcast
