DELIMITER //

CREATE PROCEDURE FindAvailableBed(
    IN p_department_id INT,
    OUT p_bed_id INT
)
BEGIN

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE department_id = p_department_id
          AND patient_id IS NULL
    LIMIT 1;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE AdmitPatient(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_time DATETIME,
    IN p_department_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_bed_id INT;
    DECLARE v_count INT;

    -- Bắt lỗi SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET p_message = 'Lỗi hệ thống';
    END;

    START TRANSACTION;

    -- Kiểm tra khoa tồn tại
    SELECT COUNT(*)
    INTO v_count
    FROM Departments
    WHERE department_id = p_department_id;

    IF v_count = 0 THEN

        ROLLBACK;

        SET p_message = 'Từ chối: Khoa không tồn tại';

    ELSE

        -- Kiểm tra bệnh nhân đang nội trú
        SELECT COUNT(*)
        INTO v_count
        FROM Beds
        WHERE patient_id = p_patient_id;

        IF v_count > 0 THEN

            ROLLBACK;

            SET p_message = 'Từ chối: Bệnh nhân đang lưu trú';

        ELSE

            -- Tìm giường trống
            CALL FindAvailableBed(
                p_department_id,
                v_bed_id
            );

            -- Hết giường
            IF v_bed_id IS NULL THEN

                ROLLBACK;

                SET p_message = 'Từ chối: Khoa hiện đã hết giường';

            ELSE

                -- Tạo lịch khám
                INSERT INTO Appointments(
                    patient_id,
                    doctor_id,
                    appointment_time
                )
                VALUES(
                    p_patient_id,
                    p_doctor_id,
                    p_appointment_time
                );

                -- Gán giường
                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = v_bed_id;

                COMMIT;

                SET p_message = 'Nhập viện thành công';

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;

CALL AdmitPatient(
    1,
    2,
    '2026-05-20 08:00:00',
    1,
    @msg
);

SELECT @msg;

CALL AdmitPatient(
    2,
    2,
    '2026-05-20 09:00:00',
    5,
    @msg
);

SELECT @msg;

CALL AdmitPatient(
    1,
    3,
    '2026-05-20 10:00:00',
    2,
    @msg
);

SELECT @msg;

CALL AdmitPatient(
    3,
    2,
    '2026-05-20 11:00:00',
    999,
    @msg
);

SELECT @msg;