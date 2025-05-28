-- 1 --
ALTER TABLE produk
ADD keterangan VARCHAR(100);

UPDATE produk
SET keterangan = 'Produk best seller'
WHERE id_produk = 1001;

SELECT * FROM produk;


-- 2 --
SELECT p.id_produk, p.nama_produk, k.nama_kategori, p.harga
FROM produk p
JOIN kategori_produk k ON p.id_kategori = k.id_kategori;


-- 3 --
SELECT * FROM produk
ORDER BY harga ASC;

SELECT * FROM produk
ORDER BY harga DESC;


-- 4 --
ALTER TABLE produk
MODIFY harga DECIMAL(10,2);

SELECT * FROM produk;


-- 5 --
-- left & right join --
SELECT p.nama_produk, d.jumlah
FROM produk p
LEFT JOIN detail_transaksi d ON p.id_produk = d.id_produk;

SELECT p.nama_produk, d.jumlah
FROM produk p
RIGHT JOIN detail_transaksi d ON p.id_produk = d.id_produk;

INSERT INTO produk VALUES
(1004, 'Mainan Gantung Musik', 104, 80000, 15, 'HappyBaby', '');
(1005, 'Topi Bayi Lucu', 101, 30000, 10, 'CuteBaby', 'produk baru');

select * from detail_transaksi;


-- self join --
SELECT p1.nama_pelanggan AS Pelanggan1, p2.nama_pelanggan AS Pelanggan2
FROM pelanggan p1
JOIN pelanggan p2 ON p1.no_hp = p2.no_hp AND p1.id_pelanggan != p2.id_pelanggan;

UPDATE pelanggan
SET no_hp = '089876543210'
WHERE id_pelanggan = 202;

select * from pelanggan;


-- 6 --
SELECT * FROM produk WHERE harga > 70000;

SELECT * FROM produk WHERE stok <= 5;

SELECT * FROM transaksi WHERE total_harga != 120000;

SELECT * FROM produk WHERE harga >= 50000 AND harga <= 100000;

SELECT * FROM pelanggan WHERE nama_pelanggan = 'Ivory';
