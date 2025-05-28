ALTER TABLE transaksi
ADD STATUS VARCHAR(20);

ALTER TABLE produk
ADD tanggal_masuk DATE;

UPDATE produk SET tanggal_masuk = '2025-04-01' WHERE id_produk = 1001;
UPDATE produk SET tanggal_masuk = '2025-03-15' WHERE id_produk = 1002;
UPDATE produk SET tanggal_masuk = '2025-04-10' WHERE id_produk = 1003;
UPDATE produk SET tanggal_masuk = '2025-01-05' WHERE id_produk = 1004;
UPDATE produk SET tanggal_masuk = '2025-05-01' WHERE id_produk = 1005;

UPDATE transaksi SET STATUS = 'lunas' WHERE id_transaksi = 301;
UPDATE transaksi SET STATUS = 'belum bayar' WHERE id_transaksi = 302;
UPDATE transaksi SET STATUS = 'lunas' WHERE id_transaksi = 303;
UPDATE transaksi SET STATUS = 'belum bayar' WHERE id_transaksi = 304;

UPDATE transaksi SET tanggal = '2023-01-01' WHERE id_transaksi = 301;

INSERT INTO transaksi (id_transaksi, tanggal, id_pelanggan, total_harga, STATUS)
VALUES
(308, '2025-03-20', 204, 110000, 'belum lunas'),
(309, '2025-04-02', 201, 95000, 'belum lunas'),
(310, '2025-04-04', 202, 170000, 'belum lunas'), 
(305, '2025-03-10', 201, 90000, 'belum lunas'),
(306, '2025-03-15', 202, 150000, 'belum lunas'),
(307, '2025-04-01', 203, 180000, 'belum lunas');

DELETE FROM transaksi
WHERE id_transaksi IN (319, 320, 321, 322, 323, 324, 325, 326);

INSERT INTO transaksi (id_transaksi, id_pelanggan, tanggal, total_harga, status)
VALUES 
(319, 210, '2025-05-01', 100000, 'sukses'),
(320, 210, '2025-05-05', 120000, 'sukses'),
(321, 211, '2025-05-03', 250000, 'sukses'),
(322, 211, '2025-05-07', 100000, 'sukses'),
(323, 212, '2025-05-02', 70000, 'sukses'),
(324, 213, '2025-05-04', 150000, 'sukses'),
(325, 213, '2025-05-06', 80000, 'sukses'),
(326, 213, '2025-05-09', 70000, 'sukses');



INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, no_hp)
VALUES (205, 'Nicolas', '081122334455');

INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, no_hp) VALUES
(206, 'Choco', '081234567890'),
(207, 'Vanilla', '081298765432'),
(208, 'Berry', '082123456789'),
(209, 'Cherry', '082112233445');

INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, no_hp)
VALUES
(210, 'Diana', '081234543890'),
(211, 'Erick', '081987084321'),
(212, 'Friska', '082092233445'),
(213, 'Gilang', '081998856765');





-- 1 --
DELIMITER //

CREATE PROCEDURE tampil_produk_seminggu()
BEGIN
	SELECT * FROM produk
	WHERE tanggal_masuk >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
END //

DELIMITER ;

CALL tampil_produk_seminggu();


-- 2 --
DELIMITER //

CREATE PROCEDURE hapus_transaksi_lama()
BEGIN
  DELETE FROM detail_transaksi 
  WHERE id_transaksi IN (
    SELECT id_transaksi FROM transaksi
    WHERE tanggal < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    AND status = 'lunas'
  );

  DELETE FROM transaksi 
  WHERE tanggal < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND status = 'lunas';
END //

DELIMITER ;


DROP PROCEDURE IF EXISTS hapus_transaksi_lama;
CALL hapus_transaksi_lama();
select * from transaksi;

-- 3 --
DELIMITER //

CREATE PROCEDURE ubah_status_transaksi()
BEGIN
	UPDATE transaksi
	SET status = 'sukses'
	WHERE status != 'sukses'
	LIMIT 7;
END //

DELIMITER ;

CALL ubah_status_transaksi();
select * from transaksi;

-- 4 --
DELIMITER //

CREATE PROCEDURE edit_pelanggan(
	IN pid INT,
	IN pnama VARCHAR(50),
	IN pno_hp VARCHAR(50)
)
BEGIN
	IF NOT EXISTS (
		SELECT * FROM transaksi WHERE id_pelanggan = pid
	) THEN
		UPDATE pelanggan SET nama_pelanggan = pnama, no_hp = pno_hp WHERE id_pelanggan = pid;
	END IF;
END //

DELIMITER ;

CALL edit_pelanggan(205, 'Nicolas', '081122334455');
select * from pelanggan;
SELECT * FROM transaksi WHERE id_pelanggan = 205;


-- 5 --
DELIMITER //

CREATE PROCEDURE UpdateBerdasarkanTotal()
BEGIN
    DECLARE id_tertinggi VARCHAR(20);
    DECLARE id_terendah VARCHAR(20);

    -- Buat temporary table
    CREATE TEMPORARY TABLE temp_total AS
    SELECT id_pelanggan, SUM(total_harga) AS total_transaksi
    FROM transaksi
    WHERE tanggal >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
    GROUP BY id_pelanggan;

    -- Ambil id_pelanggan dengan total transaksi tertinggi
    SELECT id_pelanggan INTO id_tertinggi
    FROM temp_total
    ORDER BY total_transaksi DESC
    LIMIT 1;

    -- Ambil id_pelanggan dengan total transaksi terendah
    SELECT id_pelanggan INTO id_terendah
    FROM temp_total
    ORDER BY total_transaksi ASC
    LIMIT 1;

    -- Update status untuk pelanggan dengan transaksi terbesar
    UPDATE transaksi
    SET status = 'aktif'
    WHERE id_pelanggan = id_tertinggi
      AND tanggal >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

    -- Update status untuk pelanggan dengan transaksi terkecil
    UPDATE transaksi
    SET status = 'non-aktif'
    WHERE id_pelanggan = id_terendah
      AND tanggal >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

    -- Update sisanya menjadi pasif
    UPDATE transaksi
    SET status = 'pasif'
    WHERE id_pelanggan NOT IN (id_tertinggi, id_terendah)
      AND tanggal >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

    -- Hapus temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_total;
ENd //

DELIMITER ;

DROP PROCEDURE IF EXISTS update_status_terbaru;
CALL UpdateBerdasarkanTotal();
select * from transaksi;
SELECT 
    t.id_transaksi,
    t.tanggal,
    p.nama_pelanggan,
    t.total_harga,
    t.status
FROM transaksi t
JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan
WHERE t.tanggal >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
ORDER BY t.status DESC;0



-- 6 --
DELIMITER //

CREATE PROCEDURE tampil_transaksi_sukses()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tid INT;

    -- Cursor untuk ambil ID transaksi sukses 1 bulan terakhir
    DECLARE cur CURSOR FOR 
        SELECT id_transaksi 
        FROM transaksi
        WHERE STATUS = 'sukses' AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

    -- Penanganan akhir cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Buka cursor
    OPEN cur;

    -- Looping melalui hasil cursor
    loop_trans: LOOP
        FETCH cur INTO tid;
        IF done THEN
            LEAVE loop_trans;
        END IF;

        -- Menampilkan data per transaksi
        SELECT * FROM transaksi WHERE id_transaksi = tid;
    END LOOP;

    -- Tutup cursor
    CLOSE cur;
END //

DELIMITER ;

CALL tampil_transaksi_sukses();
select * from transaksi;

SELECT COUNT(*) AS jumlah_transaksi_sukses
FROM transaksi
WHERE status = 'sukses'
  AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
  
SELECT * 
FROM transaksi
WHERE STATUS = 'sukses'
  AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

  
drop procedure tampil_transaksi_sukses;
