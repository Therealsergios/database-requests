with t1 as (SELECT courier_id,
                   round(count(distinct order_id))::integer as orders_count,
                   rank() OVER(ORDER BY round(count(distinct order_id)) desc, courier_id asc) as courier_rank
            FROM   courier_actions
            WHERE  action = 'deliver_order'
            GROUP BY courier_id), t2 as (SELECT count(distinct courier_id) as total_couriers
                             FROM   courier_actions)
SELECT courier_id,
       orders_count,
       courier_rank
FROM   t1
WHERE  courier_rank <= (SELECT round(total_couriers * 0.1)
                        FROM   t2)
ORDER BY courier_rank