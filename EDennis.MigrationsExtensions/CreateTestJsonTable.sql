/****** Object:  StoredProcedure [_maintenance].[SaveTestJson]    Script Date: 6/4/2018 12:15:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-05-24
-- Description:	Creates a TestJson table
-- =============================================
CREATE TABLE _maintenance.TestJson(
       Project varchar(100),
       Class varchar(100),
       Method varchar(100),
       FileName varchar(100),
       Json varchar(max),
       constraint pk_maintenanceTestJson 
              primary key (Project, Class, Method, FileName)
);
