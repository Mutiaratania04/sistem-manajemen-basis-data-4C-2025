-- 1 --
DELIMITER //

CREATE PROCEDURE UpdateDataProduk (
    IN p_id_produk INT,
    IN p_nilai_baru INT,
    OUT p_status VARCHAR(50)
)
BEGIN
    UPDATE produk
    SET harga = p_nilai_baru
    WHERE id_produk = p_id_produk;

    SET p_status = CONCAT('Jumlah baris diupdate: ', ROW_COUNT());
END //

DELIMITER ;

CALL UpdateDataProduk(1002, 200000, @status);
SELECT @status;
SELECT * FROM produk;

DROP PROCEDURE UpdateDataProduk;


-- 2 --
DELIMITER //

CREATE PROCEDURE CountTransaksi (
    OUT jumlah INT
)
BEGIN
    SELECT COUNT(*) INTO jumlah FROM transaksi;
END //

DELIMITER ;

CALL CountTransaksi(@jumlah);
SELECT @jumlah;
select * from transaksi;


-- 3 --
DELIMITER //

CREATE PROCEDURE GetDataProdukByID (
    IN p_id INT,
    OUT p_nama_produk VARCHAR(50),
    OUT p_harga INT,
    OUT p_stok INT
)
BEGIN
    SELECT nama_produk, harga, stok
    INTO p_nama_produk, p_harga, p_stok
    FROM produk
    WHERE id_produk = p_id;
END //

DELIMITER ;

CALL GetDataProdukByID(1002, @nama, @harga, @stok);
SELECT @nama, @harga, @stok;
select * from produk;


-- 4 --
DELIMITER //

CREATE PROCEDURE UpdateTransaksi (
    IN p_id INT,
    INOUT p_field1 INT,
    INOUT p_field2 INT
)
BEGIN
    -- Ambil nilai lama dari database
    SELECT 
        IFNULL(p_field1, jumlah),
        IFNULL(p_field2, subtotal)
    INTO 
        p_field1,
        p_field2
    FROM detail_transaksi
    WHERE id_detail = p_id;

    -- Update data dengan nilai yang sudah dicek
    UPDATE detail_transaksi
    SET jumlah = p_field1,
        subtotal = p_field2
    WHERE id_detail = p_id;
END //

DELIMITER ;

SET @jumlah = 11;         
SET @subtotal = 140000;

CALL UpdateFieldTransaksi(408, @jumlah, @subtotal);

SELECT @jumlah, @subtotal;

SELECT * FROM detail_transaksi WHERE id_detail = 408;

DROP PROCEDURE IF EXISTS UpdateTransaksi;


-- 5 --
DELIMITER //

CREATE PROCEDURE DeleteEntriesByIDProduk (
    IN p_id_produk INT
)
BEGIN
    DELETE FROM detail_transaksi WHERE id_produk = p_id_produk;
    
    DELETE FROM produk WHERE id_produk = p_id_produk;
END //

DELIMITER ;


CALL DeleteEntriesByIDProduk(1004);
select * from produk;
DROP PROCEDURE IF EXISTS DeleteEntriesByIDProduk;

