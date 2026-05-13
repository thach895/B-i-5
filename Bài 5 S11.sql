DELIMITER //

CREATE PROCEDURE FindAvailableBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)
BEGIN

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_dept_id
    AND patient_id IS NULL
    LIMIT 1;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE TransferPatientBed(
    IN p_patient_id INT,
    IN p_new_dept_id INT,
    OUT p_new_bed_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_current_bed_id INT;
    DECLARE v_dept_name VARCHAR(100);
    DECLARE v_completed_count INT DEFAULT 0;

    START TRANSACTION;

    -- Kiểm tra khoa tồn tại
    SELECT dept_name
    INTO v_dept_name
    FROM Departments
    WHERE dept_id = p_new_dept_id;

    IF v_dept_name IS NULL THEN

        SET p_new_bed_id = NULL;
        SET p_message = 'Lỗi: Khoa không tồn tại';

        ROLLBACK;

    ELSE

        -- Kiểm tra bệnh nhân đã xuất viện chưa
        SELECT COUNT(*)
        INTO v_completed_count
        FROM Appointments
        WHERE patient_id = p_patient_id
        AND status = 'Completed';

        IF v_completed_count > 0 THEN

            SET p_new_bed_id = NULL;
            SET p_message = 'Từ chối: Bệnh nhân đã xuất viện';

            ROLLBACK;

        ELSE

            -- Gọi procedure phụ tìm giường trống
            CALL FindAvailableBed(
                p_new_dept_id,
                p_new_bed_id
            );

            -- Hết giường
            IF p_new_bed_id IS NULL THEN

                SET p_message = CONCAT(
                    'Từ chối: Khoa ',
                    v_dept_name,
                    ' đã hết giường'
                );

                ROLLBACK;

            ELSE

                -- Lấy giường hiện tại
                SELECT bed_id
                INTO v_current_bed_id
                FROM Beds
                WHERE patient_id = p_patient_id
                LIMIT 1;

                -- Giải phóng giường cũ
                UPDATE Beds
                SET patient_id = NULL
                WHERE bed_id = v_current_bed_id;

                -- Gán bệnh nhân vào giường mới
                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = p_new_bed_id;

                SET p_message = 'Chuyển giường thành công';

                COMMIT;

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;