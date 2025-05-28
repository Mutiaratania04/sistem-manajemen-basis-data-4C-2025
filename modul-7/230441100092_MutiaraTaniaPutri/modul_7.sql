-- 1 --
-- before insert pada produk
DELIMITER //

CREATE TRIGGER before_insert_produk
BEFORE INSERT ON produk
FOR EACH ROW
BEGIN
  IF NEW.harga < 0 OR NEW.stok < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Harga dan Stok tidak boleh negatif';
  END IF;
END //

DELIMITER ;

INSERT INTO produk (id_produk, nama_produk, harga, stok)
VALUES (1006, 'Produk A', -1000, 10);

INSERT INTO produk (id_produk, nama_produk, harga, stok)
VALUES (1006, 'Produk A', 15000, 5);

SELECT * FROM produk;

DELETE FROM produk
WHERE id_produk = 0;

drop trigger if exists before_insert_produk;

show triggers;

-- before update pada transaksi
DELIMITER //

CREATE TRIGGER before_update_transaksi
BEFORE UPDATE ON transaksi
FOR EACH ROW
BEGIN
  IF NEW.total_harga < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Total harga tidak boleh negatif';
  END IF;
END //

DELIMITER ;

UPDATE transaksi SET total_harga = -1000 WHERE id_transaksi = 303;

UPDATE transaksi SET total_harga = 1000 WHERE id_transaksi = 303;

select * from transaksi;






-- before delete pada pelanggan
DELIMITER //

CREATE TRIGGER before_delete_pelanggan
BEFORE DELETE ON pelanggan
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM transaksi WHERE id_pelanggan = OLD.id_pelanggan
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Pelanggan tidak bisa dihapus karena memiliki transaksi';
  END IF;
END //

DELIMITER ;

DELETE FROM pelanggan WHERE id_pelanggan = 203;
select * from transaksi;
select * from pelanggan;
select * from detail_transaksi;
DELETE FROM transaksi WHERE id_transaksi = 307;



-- 2 --
-- after insert pada transaksi
DELIMITER //

CREATE TRIGGER after_insert_transaksi
AFTER INSERT ON transaksi
FOR EACH ROW
BEGIN
  IF NEW.STATUS IS NULL THEN
    UPDATE transaksi
    SET STATUS = 'belum bayar'
    WHERE id_transaksi = NEW.id_transaksi;
  END IF;
END //

DELIMITER ;

INSERT INTO transaksi (id_transaksi, tanggal, id_pelanggan, total_harga) 
VALUES (328, CURDATE(), 204, 40000);

UPDATE transaksi
SET STATUS = 'belum bayar'
WHERE id_transaksi = 328;

select * from transaksi;

-- after update pada produk
CREATE TABLE log_edit_pelanggan (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_pelanggan INT,
    nama_lama VARCHAR(50),
    nama_baru VARCHAR(50),
    waktu_edit TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DELIMITER //

CREATE TRIGGER after_update_pelanggan
AFTER UPDATE ON pelanggan
FOR EACH ROW
BEGIN
  IF OLD.nama_pelanggan != NEW.nama_pelanggan THEN
    INSERT INTO log_edit_pelanggan (id_pelanggan, nama_lama, nama_baru)
    VALUES (NEW.id_pelanggan, OLD.nama_pelanggan, NEW.nama_pelanggan);
  END IF;
END //

DELIMITER ;

UPDATE pelanggan 
SET nama_pelanggan = 'Lionel' 
WHERE id_pelanggan = 204;

select * from  pelanggan;

select * from log_edit_pelanggan;


-- after delete pada transaksi
CREATE TABLE log_transaksi_dihapus (
  id_transaksi INT,
  tanggal DATE,
  id_pelanggan INT,
  total_harga INT,
  status VARCHAR(20),
  waktu_dihapus TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER after_delete_transaksi
AFTER DELETE ON transaksi
FOR EACH ROW
BEGIN
  INSERT INTO log_transaksi_dihapus (id_transaksi, tanggal, id_pelanggan, total_harga, status)
  VALUES (OLD.id_transaksi, OLD.tanggal, OLD.id_pelanggan, OLD.total_harga, OLD.status);
END //

DELIMITER ;

DELETE FROM detail_transaksi WHERE id_transaksi = 304;
DELETE FROM transaksi WHERE id_transaksi = 304;


SELECT * FROM log_transaksi_dihapus;

select * from transaksi;

