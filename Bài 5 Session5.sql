SELECT 
    full_name AS Ten_Khach_Hang,
    CASE
        WHEN total_orders IS NULL THEN 'Mới'
        WHEN total_orders > 500 THEN 'Kim Cương'
        WHEN total_orders BETWEEN 100 AND 500 THEN 'Vàng'
        ELSE 'Bạc'
    END AS Xep_Hang
FROM Users;