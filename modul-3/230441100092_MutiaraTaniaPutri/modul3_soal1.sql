USE umkm_jawa_barat;

-- no 1
DELIMITER //

CREATE PROCEDURE AddUMKM (IN p_nama_usaha VARCHAR(200), IN p_jumlah_karyawan INT)
BEGIN
  INSERT INTO umkm (
    nama_usaha,
    id_pemilik,
    id_kategori,  
    id_skala,
    id_kabupaten_kota,
    alamat_usaha,
    nib,
    npwp,
    tahun_berdiri,
    jumlah_karyawan,
    total_aset,
    omzet_per_tahun,
    deskripsi_usaha,
    tanggal_registrasi
  ) VALUES (
    p_nama_usaha,
    1, 1, 1, 1,
    'Alamat contoh',
    'NIB0001', 'NPWP0001',
    2024,
    p_jumlah_karyawan,
    10000000.00, 50000000.00,
    'Usaha baru',
    CURDATE()
  );
END //

DELIMITER ;

CALL AddUMKM('Toko Baju Andini', 5);

SELECT * FROM umkm;


-- no2
DELIMITER //

CREATE PROCEDURE UpdateKategoriUMKM(
  IN p_id_kategori INT,
  IN p_nama_baru VARCHAR(100)
)
BEGIN
  UPDATE kategori_umkm
  SET nama_kategori = p_nama_baru
  WHERE id_kategori = p_id_kategori;
END //

DELIMITER ;

CALL UpdateKategoriUMKM(3, 'Kuliner');

SELECT * FROM kategori_umkm;



-- no 3 

DELIMITER //

CREATE PROCEDURE DeletePemilikUMKM(IN p_id_pemilik INT)
BEGIN
    
    DELETE FROM produk_umkm WHERE id_umkm IN (SELECT id_umkm FROM umkm WHERE id_pemilik = p_id_pemilik);

    
    DELETE FROM umkm WHERE id_pemilik = p_id_pemilik;

   
    DELETE FROM pemilik_umkm WHERE id_pemilik = p_id_pemilik;
END //

DELIMITER ;

CALL DeletePemilikUMKM(3);

SELECT * FROM pemilik_umkm;

DROP PROCEDURE IF EXISTS DeletePemilikUMKM;



-- no 4

DELIMITER //

CREATE PROCEDURE AddProduk(IN p_id_umkm INT, IN p_nama_produk VARCHAR(200), IN p_harga DECIMAL(15,2))
BEGIN
    INSERT INTO produk_umkm (id_umkm, nama_produk, harga)
    VALUES (p_id_umkm, p_nama_produk, p_harga);
END //

DELIMITER ;

CALL AddProduk(1, 'Produk baru', 50000.00);

SELECT * FROM produk_umkm;


-- no5
DELIMITER //

CREATE PROCEDURE GetUMKMByID(IN p_id_umkm INT, OUT p_nama_usaha VARCHAR(200), OUT p_alamat_usaha TEXT, OUT p_nib VARCHAR(50), OUT p_npwp VARCHAR(20), OUT p_tahun_berdiri YEAR, OUT p_jumlah_karyawan INT, OUT p_total_aset DECIMAL(15,2), OUT p_omzet_per_tahun DECIMAL(15,2), OUT p_deskripsi_usaha TEXT, OUT p_tanggal_registrasi DATE)
BEGIN
    SELECT nama_usaha, alamat_usaha, nib, npwp, tahun_berdiri, jumlah_karyawan, total_aset, omzet_per_tahun, deskripsi_usaha, tanggal_registrasi
    INTO p_nama_usaha, p_alamat_usaha, p_nib, p_npwp, p_tahun_berdiri, p_jumlah_karyawan, p_total_aset, p_omzet_per_tahun, p_deskripsi_usaha, p_tanggal_registrasi
    FROM umkm
    WHERE id_umkm = p_id_umkm;
END //

DELIMITER ;


CALL GetUMKMByID(1, @nama_usaha, @alamat_usaha, @nib, @npwp, @tahun_berdiri, @jumlah_karyawan, @total_aset, @omzet_per_tahun, @deskripsi_usaha, @tanggal_registrasi);

SELECT @nama_usaha, @alamat_usaha, @nib, @npwp, @tahun_berdiri, @jumlah_karyawan, @total_aset, @omzet_per_tahun, @deskripsi_usaha, @tanggal_registrasi;

