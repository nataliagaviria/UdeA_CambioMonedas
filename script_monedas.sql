/*Ejecutar primero*/
CREATE DATABASE Monedas; 

--Para las siguientes instrucciones, se debe cambiar la conexión

/* Crear tabla MONEDA */
CREATE TABLE IF NOT EXISTS Moneda (
    Id      SERIAL PRIMARY KEY,
    Moneda  VARCHAR(100) NOT NULL,
    Sigla   VARCHAR(5)   NOT NULL,
    Simbolo VARCHAR(5)   NULL,
    Emisor  VARCHAR(100) NULL,
    Imagen  BYTEA        NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ixMoneda ON Moneda(Moneda);

CREATE TABLE IF NOT EXISTS CambioMoneda (
    Id       SERIAL PRIMARY KEY,
    IdMoneda INT   NOT NULL,
    CONSTRAINT fkCambioMoneda_IdMoneda FOREIGN KEY (IdMoneda)
        REFERENCES Moneda(Id),
    Fecha    DATE  NOT NULL,
    Cambio   FLOAT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ixCambioMoneda ON CambioMoneda(IdMoneda, Fecha);

CREATE TABLE IF NOT EXISTS Pais (
    Id          SERIAL PRIMARY KEY,
    Pais        VARCHAR(50) NOT NULL,
    CodigoAlfa2 VARCHAR(5)  NOT NULL,
    CodigoAlfa3 VARCHAR(5)  NOT NULL,
    IdMoneda    INT         NOT NULL,
    CONSTRAINT fkPais_IdMoneda FOREIGN KEY (IdMoneda)
        REFERENCES Moneda(Id),
    Mapa        BYTEA NULL,
    Bandera     BYTEA NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ixPais ON Pais(Pais);


-- ObtenerOCrearMoneda
CREATE OR REPLACE FUNCTION ObtenerOCrearMoneda(
    p_Moneda  VARCHAR(100),
    p_Sigla   VARCHAR(5),
    p_Simbolo VARCHAR(5)   DEFAULT NULL,
    p_Emisor  VARCHAR(100) DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_Id INT;
BEGIN
    INSERT INTO Moneda (Moneda, Sigla, Simbolo, Emisor)
    VALUES (p_Moneda, p_Sigla, p_Simbolo, p_Emisor)
    ON CONFLICT (Moneda) DO NOTHING;

    SELECT Id INTO v_Id
    FROM Moneda
    WHERE Moneda = p_Moneda;

    RETURN v_Id;
END;
$$;


-- RegistrarCambioMoneda
CREATE OR REPLACE FUNCTION RegistrarCambioMoneda(
    p_IdMoneda INT,
    p_Fecha    DATE,
    p_Cambio   FLOAT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO CambioMoneda (IdMoneda, Fecha, Cambio)
    VALUES (p_IdMoneda, p_Fecha, p_Cambio)
    ON CONFLICT (IdMoneda, Fecha)
    DO UPDATE SET Cambio = EXCLUDED.Cambio;
END;
$$;



-- 3. INSERCION DE MONEDAS 

DO $$
DECLARE
    v_IdUSD INT;
    v_IdEUR INT;
    v_IdGBP INT;
    v_IdJPY INT;
BEGIN
    v_IdUSD := ObtenerOCrearMoneda('Dolar estadounidense', 'USD', '$',  'Reserva Federal de los Estados Unidos (FED)');
    v_IdEUR := ObtenerOCrearMoneda('Euro',                 'EUR', '€',  'Banco Central Europeo (BCE)');
    v_IdGBP := ObtenerOCrearMoneda('Libra esterlina',      'GBP', '£',  'Banco de Inglaterra (Bank of England)');
    v_IdJPY := ObtenerOCrearMoneda('Yen japones',          'JPY', '¥',  'Banco de Japon (Bank of Japan)');

    RAISE NOTICE 'Monedas registradas - USD: %, EUR: %, GBP: %, JPY: %',
        v_IdUSD, v_IdEUR, v_IdGBP, v_IdJPY;
END;
$$;


/* 4. INSERCION DE REGISTROS DE CAMBIO DE MONEDA
--    Rango: 2026-03-01 al 2026-04-30 (61 dias = 61 registros por moneda)
--    Total: 244 registros (61 x 4 monedas)
--    Tipo de cambio: Pesos colombianos (COP) por unidad de moneda extranjera
--    Dataset de prueba deterministico - valores aproximados historicos (fechas futuras)
--    Fuentes: https://www.exchangerate.host/ | https://www.banrep.gov.co/
*/

DO $$
DECLARE
    v_IdUSD INT;
    v_IdEUR INT;
    v_IdGBP INT;
    v_IdJPY INT;
BEGIN
    -- Obtener Ids de monedas
    SELECT Id INTO v_IdUSD FROM Moneda WHERE Sigla = 'USD';
    SELECT Id INTO v_IdEUR FROM Moneda WHERE Sigla = 'EUR';
    SELECT Id INTO v_IdGBP FROM Moneda WHERE Sigla = 'GBP';
    SELECT Id INTO v_IdJPY FROM Moneda WHERE Sigla = 'JPY';

    -- USD (Dolar estadounidense) -> COP
    -- Rango de referencia: ~4.180 - ~4.420 COP por USD
	
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-01', 4203.50);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-02', 4198.75);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-03', 4215.20);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-04', 4221.60);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-05', 4235.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-06', 4242.10);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-07', 4228.45);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-08', 4218.30);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-09', 4209.90);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-10', 4197.65);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-11', 4185.20);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-12', 4193.40);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-13', 4208.75);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-14', 4220.15);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-15', 4231.50);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-16', 4245.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-17', 4258.20);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-18', 4271.65);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-19', 4285.30);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-20', 4298.75);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-21', 4312.10);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-22', 4325.40);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-23', 4338.90);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-24', 4351.25);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-25', 4362.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-26', 4375.15);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-27', 4388.60);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-28', 4401.30);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-29', 4392.75);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-30', 4380.20);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-03-31', 4368.50);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-01', 4355.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-02', 4341.25);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-03', 4328.60);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-04', 4315.90);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-05', 4302.35);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-06', 4289.70);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-07', 4276.15);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-08', 4263.40);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-09', 4250.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-10', 4238.25);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-11', 4225.60);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-12', 4213.90);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-13', 4201.35);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-14', 4215.70);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-15', 4228.15);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-16', 4241.50);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-17', 4255.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-18', 4268.25);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-19', 4281.60);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-20', 4294.90);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-21', 4308.35);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-22', 4321.70);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-23', 4335.15);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-24', 4348.50);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-25', 4361.80);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-26', 4375.25);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-27', 4388.60);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-28', 4401.90);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-29', 4415.35);
    PERFORM RegistrarCambioMoneda(v_IdUSD, '2026-04-30', 4408.70);

    
    -- EUR (Euro) -> COP
    -- Rango de referencia: ~4.550 - ~4.800 COP por EUR
   
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-01', 4572.30);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-02', 4561.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-03', 4583.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-04', 4595.20);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-05', 4612.75);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-06', 4628.40);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-07', 4615.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-08', 4603.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-09', 4590.60);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-10', 4577.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-11', 4564.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-12', 4578.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-13', 4595.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-14', 4611.35);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-15', 4628.70);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-16', 4645.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-17', 4661.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-18', 4678.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-19', 4694.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-20', 4711.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-21', 4728.35);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-22', 4745.70);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-23', 4762.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-24', 4778.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-25', 4794.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-26', 4780.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-27', 4765.60);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-28', 4751.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-29', 4738.35);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-30', 4724.70);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-03-31', 4711.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-01', 4697.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-02', 4683.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-03', 4670.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-04', 4656.60);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-05', 4643.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-06', 4630.35);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-07', 4616.70);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-08', 4603.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-09', 4589.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-10', 4575.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-11', 4562.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-12', 4578.60);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-13', 4595.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-14', 4612.35);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-15', 4628.70);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-16', 4645.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-17', 4661.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-18', 4678.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-19', 4695.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-20', 4711.60);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-21', 4728.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-22', 4745.35);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-23', 4761.70);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-24', 4778.15);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-25', 4794.50);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-26', 4780.80);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-27', 4767.25);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-28', 4753.60);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-29', 4739.90);
    PERFORM RegistrarCambioMoneda(v_IdEUR, '2026-04-30', 4726.35);

    -- GBP (Libra esterlina) -> COP
    -- Rango de referencia: ~5.300 - ~5.600 COP por GBP

	PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-01', 5318.40);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-02', 5305.75);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-03', 5328.20);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-04', 5341.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-05', 5358.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-06', 5375.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-07', 5361.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-08', 5348.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-09', 5334.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-10', 5320.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-11', 5307.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-12', 5321.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-13', 5338.15);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-14', 5354.50);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-15', 5370.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-16', 5387.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-17', 5403.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-18', 5420.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-19', 5437.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-20', 5453.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-21', 5470.15);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-22', 5486.50);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-23', 5502.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-24', 5519.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-25', 5535.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-26', 5521.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-27', 5508.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-28', 5494.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-29', 5481.15);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-30', 5467.50);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-03-31', 5453.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-01', 5440.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-02', 5426.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-03', 5412.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-04', 5399.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-05', 5385.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-06', 5372.15);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-07', 5358.50);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-08', 5344.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-09', 5331.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-10', 5317.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-11', 5303.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-12', 5318.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-13', 5334.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-14', 5351.15);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-15', 5367.50);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-16', 5383.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-17', 5400.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-18', 5416.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-19', 5432.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-20', 5449.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-21', 5465.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-22', 5482.15);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-23', 5498.50);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-24', 5514.80);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-25', 5531.25);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-26', 5517.60);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-27', 5503.90);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-28', 5490.35);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-29', 5476.70);
    PERFORM RegistrarCambioMoneda(v_IdGBP, '2026-04-30', 5463.15);

    -- JPY (Yen japones) -> COP
    -- Rango de referencia: ~27.50 - ~30.00 COP por JPY

	
	PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-01', 27.82);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-02', 27.76);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-03', 27.91);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-04', 27.98);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-05', 28.09);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-06', 28.17);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-07', 28.11);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-08', 28.04);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-09', 27.96);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-10', 27.88);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-11', 27.80);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-12', 27.87);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-13', 27.96);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-14', 28.05);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-15', 28.14);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-16', 28.23);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-17', 28.32);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-18', 28.41);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-19', 28.50);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-20', 28.60);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-21', 28.69);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-22', 28.79);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-23', 28.89);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-24', 28.98);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-25', 29.08);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-26', 29.01);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-27', 28.93);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-28', 28.85);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-29', 28.78);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-30', 28.70);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-03-31', 28.62);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-01', 28.54);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-02', 28.46);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-03', 28.38);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-04', 28.30);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-05', 28.22);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-06', 28.14);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-07', 28.06);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-08', 27.98);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-09', 27.90);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-10', 27.82);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-11', 27.74);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-12', 27.83);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-13', 27.93);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-14', 28.02);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-15', 28.12);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-16', 28.22);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-17', 28.31);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-18', 28.41);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-19', 28.51);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-20', 28.61);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-21', 28.70);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-22', 28.80);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-23', 28.90);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-24', 29.00);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-25', 29.10);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-26', 29.03);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-27', 28.95);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-28', 28.87);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-29', 28.79);
    PERFORM RegistrarCambioMoneda(v_IdJPY, '2026-04-30', 28.71);

    RAISE NOTICE 'Registros de cambio de moneda insertados/actualizados correctamente.';
END;
$$;


-- 5. CONSULTAS DE VALIDACION

-- Conteo total de monedas registradas
SELECT COUNT(*) AS total_monedas FROM Moneda;

-- Conteo de registros de cambio por moneda
SELECT
    m.Sigla,
    m.Moneda,
    COUNT(c.Id)    AS total_registros,
    MIN(c.Fecha)   AS fecha_inicio,
    MAX(c.Fecha)   AS fecha_fin,
    MIN(c.Cambio)  AS cambio_minimo,
    MAX(c.Cambio)  AS cambio_maximo,
    ROUND(AVG(c.Cambio)::NUMERIC, 4) AS cambio_promedio
FROM Moneda m
JOIN CambioMoneda c ON c.IdMoneda = m.Id
GROUP BY m.Id, m.Sigla, m.Moneda
ORDER BY m.Sigla;

-- Conteo total de registros de cambio (debe ser 244)
SELECT COUNT(*) AS total_cambios FROM CambioMoneda;

-- Verificacion: registros por mes y moneda
SELECT
    m.Sigla,
    TO_CHAR(c.Fecha, 'YYYY-MM') AS mes,
    COUNT(*)                    AS registros_mes
FROM Moneda m
JOIN CambioMoneda c ON c.IdMoneda = m.Id
GROUP BY m.Sigla, TO_CHAR(c.Fecha, 'YYYY-MM')
ORDER BY m.Sigla, mes;


-- 6. CONSULTAS DE MUESTRA

-- Monedas registradas
SELECT * FROM Moneda;

-- Cambios por moneda con estadísticas
SELECT
    m.Sigla,
    m.Moneda,
    COUNT(c.Id)                       AS total_registros,
    MIN(c.Fecha)                      AS fecha_inicio,
    MAX(c.Fecha)                      AS fecha_fin,
    MIN(c.Cambio)                     AS cambio_minimo,
    MAX(c.Cambio)                     AS cambio_maximo,
    ROUND(AVG(c.Cambio)::NUMERIC, 2)  AS cambio_promedio
FROM Moneda m
JOIN CambioMoneda c ON c.IdMoneda = m.Id
GROUP BY m.Id, m.Sigla, m.Moneda
ORDER BY m.Sigla;

-- Total de registros (debe ser 244)
SELECT COUNT(*) AS total_cambios FROM CambioMoneda;

-- Muestra de los primeros 10 registros de cambio con nombre de moneda
SELECT
    m.Moneda,
    m.Sigla,
    m.Simbolo,
    c.Fecha,
    c.Cambio
FROM CambioMoneda c
JOIN Moneda m ON m.Id = c.IdMoneda
ORDER BY m.Sigla, c.Fecha
LIMIT 10;

-- Ultimos 5 registros de cambio del USD
SELECT
    m.Moneda,
    m.Sigla,
    c.Fecha,
    c.Cambio
FROM CambioMoneda c
JOIN Moneda m ON m.Id = c.IdMoneda
WHERE m.Sigla = 'USD'
ORDER BY c.Fecha DESC
LIMIT 5;

-- Cambio promedio semanal del EUR en marzo 2026
SELECT
    TO_CHAR(DATE_TRUNC('week', c.Fecha), 'YYYY-MM-DD') AS semana_inicio,
    ROUND(AVG(c.Cambio)::NUMERIC, 2)                   AS promedio_semanal
FROM CambioMoneda c
JOIN Moneda m ON m.Id = c.IdMoneda
WHERE m.Sigla = 'EUR'
  AND c.Fecha BETWEEN '2026-03-01' AND '2026-03-31'
GROUP BY DATE_TRUNC('week', c.Fecha)
ORDER BY semana_inicio;

-- Comparativa del dia 2026-04-15 para todas las monedas
SELECT
    m.Moneda,
    m.Sigla,
    m.Simbolo,
    m.Emisor,
    c.Fecha,
    c.Cambio
FROM CambioMoneda c
JOIN Moneda m ON m.Id = c.IdMoneda
WHERE c.Fecha = '2026-04-15'
ORDER BY c.Cambio DESC;

-- Verificar si las monedas existen
SELECT Id, Moneda, Sigla FROM Moneda;

-- Verificar si hay algo en CambioMoneda
SELECT COUNT(*) FROM CambioMoneda;

-- Ver si hay NULLs en IdMoneda
SELECT * FROM CambioMoneda WHERE IdMoneda IS NULL;
