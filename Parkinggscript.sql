USE [master]
GO
/****** Object:  Database [Parkingmanagment]    Script Date: 1/9/2024 2:33:33 AM ******/
CREATE DATABASE [Parkingmanagment]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Parkingmanagment', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Parkingmanagment.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Parkingmanagment_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Parkingmanagment_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Parkingmanagment] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Parkingmanagment].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Parkingmanagment] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Parkingmanagment] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Parkingmanagment] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Parkingmanagment] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Parkingmanagment] SET ARITHABORT OFF 
GO
ALTER DATABASE [Parkingmanagment] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Parkingmanagment] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Parkingmanagment] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Parkingmanagment] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Parkingmanagment] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Parkingmanagment] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Parkingmanagment] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Parkingmanagment] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Parkingmanagment] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Parkingmanagment] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Parkingmanagment] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Parkingmanagment] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Parkingmanagment] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Parkingmanagment] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Parkingmanagment] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Parkingmanagment] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Parkingmanagment] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Parkingmanagment] SET RECOVERY FULL 
GO
ALTER DATABASE [Parkingmanagment] SET  MULTI_USER 
GO
ALTER DATABASE [Parkingmanagment] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Parkingmanagment] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Parkingmanagment] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Parkingmanagment] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Parkingmanagment] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Parkingmanagment] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Parkingmanagment', N'ON'
GO
ALTER DATABASE [Parkingmanagment] SET QUERY_STORE = ON
GO
ALTER DATABASE [Parkingmanagment] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Parkingmanagment]
GO
/****** Object:  UserDefinedFunction [dbo].[getAvailableSpaceID]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create function [dbo].[getAvailableSpaceID]
 (@LotID int)
 returns int
 as
 begin
 declare @SpaceID int
  select Top 1 @SpaceID=SpaceID from ParkingSpace
 where LotID=@LotID
 order by SpaceID desc;

 set @SpaceID=@SpaceID+1;
 return @SpaceID
 end
GO
/****** Object:  UserDefinedFunction [dbo].[getLotBySub]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[getLotBySub]
(@SubCat varchar(25))
returns int
as
begin
declare @LotID int;
select @LotID=LotID from ParkingLot pl,  SubscriptionCategory sc
where sc.SubID=pl.subID
AND sc.SubCategory=@SubCat
return @LotID;
 end
GO
/****** Object:  UserDefinedFunction [dbo].[getReservedUserID]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[getReservedUserID]
				(@username varchar(25))
				returns int
		as
		begin
		declare @resID int;
		select top 1 @resID=ReservationID
		from Reservation r, [User] u
		where Username=@username AND u.UserID=r.UserID
		order by ReservationID desc
		return @resID
		end
GO
/****** Object:  UserDefinedFunction [dbo].[getTotalAmount]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[getTotalAmount]
(@exithours int, @resid int )
returns decimal (5,2)
as
begin
declare @charges decimal(5,2),@parktime time;
select @parktime=ParkTime from Reservation where ReservationID=@resID


select @charges=datediff(hour,CONVERT(TIME, dateadd(hour,@exithours,getdate()), 108),@parktime)*s.HourlyRate
from Reservation r, ParkingSpace ps, ParkingLot pl, SubscriptionCategory s
where r.LotID = ps.LotID
AND r.SpaceID=ps.SpaceID
and pl.LotID=ps.LotID
AND pl.SubID=s.SubID
AND r.ReservationID=@resID
return @charges
end
GO
/****** Object:  UserDefinedFunction [dbo].[getUserReservationID]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create function [dbo].[getUserReservationID]
		(@username varchar(25))
		returns int
		as
		begin
		declare @ResID int;
		select top 1 @ResID=ReservationID from Reservation r, [User] u
		where Username=@username AND u.UserID=r.UserID
		order by ReservationID desc
		return @ResID
		end
GO
/****** Object:  UserDefinedFunction [dbo].[loginUser]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[loginUser]
(@uname VARCHAR(25), @Password VARCHAR(25), @Role varchar(25))
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @userCount INT, @Result VARCHAR(10);

    SELECT @userCount = COUNT(*)
    FROM [User]
    WHERE Username = @uname AND Password = @Password and Role=@Role;

    -- Return 'Success' if a matching user is found, otherwise 'Fail'
    IF @userCount > 0
        SET @Result = 'Success';
    ELSE
        SET @Result = 'Fail';

    RETURN @Result;
END;
GO
/****** Object:  Table [dbo].[Feedback]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feedback](
	[FeedbackID] [int] IDENTITY(1,1) NOT NULL,
	[ReservationID] [int] NULL,
	[Date] [datetime] NULL,
	[Comment] [varchar](50) NULL,
	[Rating] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[FeedbackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Email] [varchar](25) NULL,
	[Password] [varchar](25) NULL,
	[Role] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reservation]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservation](
	[ReservationID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[VehiclePlate] [varchar](25) NULL,
	[LotID] [int] NULL,
	[SpaceID] [int] NULL,
	[ParkDate] [date] NULL,
	[ParkTime] [time](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[getFeedback]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	   create function [dbo].[getFeedback]()
		returns table
		as
		return (Select (FirstName+' '+LastName)'Name', Comment from Feedback f, [User] u, Reservation r
		where f.ReservationID=r.ReservationID AND u.UserID=r.ReservationID)
GO
/****** Object:  UserDefinedFunction [dbo].[getUserFeedback]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		create function [dbo].[getUserFeedback]
		(@username varchar(25))
		returns table
		as
		return
		(select top 1 ReservationID from Reservation r, [User] u
		where Username=@username AND u.UserID=r.UserID
		order by ReservationID desc)
GO
/****** Object:  View [dbo].[viewReservations]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		create view [dbo].[viewReservations]
		as
		select ReservationID, (FirstName+' '+LastName)'Name',VehiclePlate,LotID,SpaceID,ParkDate,ParkTime
		from Reservation r, [User] u
		where r.userID=u.UserID
GO
/****** Object:  Table [dbo].[SubscriptionCategory]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionCategory](
	[SubID] [int] IDENTITY(1,1) NOT NULL,
	[SubCategory] [varchar](25) NULL,
	[HourlyRate] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[SubID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[viewSubCats]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	   create view [dbo].[viewSubCats]
	   as
	   select distinct SubCategory
	   from SubscriptionCategory
GO
/****** Object:  UserDefinedFunction [dbo].[getUserDetail]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[getUserDetail]
(@uname varchar(25),@Password varchar(25))
returns table
as
return
(Select * from [User]
where username=@uname AND Password=@Password)
GO
/****** Object:  UserDefinedFunction [dbo].[getUserReservationIDs]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create function [dbo].[getUserReservationIDs]
		(@username varchar(25))
		returns table
		as
		return
		(select ReservationID from Reservation r, [User] u
		where Username=@username AND u.UserID=r.UserID)
GO
/****** Object:  View [dbo].[viewUsers]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[viewUsers]
as
select UserID,Username,FirstName,LastName,Email,Password
from [User]
GO
/****** Object:  View [dbo].[viewAllFeedbacks]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[viewAllFeedbacks]
as
select u.FirstName+' '+u.LastName as 'CustomerName', Comment,
Rating from Feedback f, [User] u,
Reservation r
where r.ReservationID=f.ReservationID
AND r.UserID=u.UserID
GO
/****** Object:  View [dbo].[viewUserVehicles]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[viewUserVehicles]
as
select ReservationID, u.FirstName+' '+u.LastName as 'CustomerName', VehiclePlate 
from [User] u,
Reservation r
where r.UserID=u.UserID
GO
/****** Object:  Table [dbo].[ParkingLot]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingLot](
	[LotID] [int] IDENTITY(1,1) NOT NULL,
	[SubID] [int] NULL,
	[Capacity] [int] NULL,
	[LotName] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[LotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParkingSpace]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingSpace](
	[SpaceID] [int] NOT NULL,
	[LotID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SpaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transaction]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transaction](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[ReservationID] [int] NULL,
	[ExitTime] [time](7) NULL,
	[TotalAmount] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vehicle]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicle](
	[VehicleID] [int] IDENTITY(1,1) NOT NULL,
	[LicensePlate] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehicleOwner]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleOwner](
	[VehicleID] [int] NULL,
	[UserID] [int] NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Feedback] ON 

INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (1, 1, CAST(N'2024-01-10T09:30:00.000' AS DateTime), N'Good service!', 4)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (2, 2, CAST(N'2024-01-11T11:45:00.000' AS DateTime), N'Satisfactory.', 3)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (3, 3, CAST(N'2024-01-12T13:15:00.000' AS DateTime), N'Excellent experience!', 5)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (4, 4, CAST(N'2024-01-13T15:30:00.000' AS DateTime), N'Not happy with the service.', 1)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (5, 5, CAST(N'2024-01-14T17:45:00.000' AS DateTime), N'Highly recommended!', 5)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (6, 5, CAST(N'2024-01-05T21:02:01.567' AS DateTime), N'Excelent Work', 5)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (7, 23, CAST(N'2024-01-08T00:11:17.827' AS DateTime), N'Need Improvment', 2)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (8, 1, CAST(N'2024-01-08T01:15:54.223' AS DateTime), N'Good', 4)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (9, 15, CAST(N'2024-01-08T01:17:38.717' AS DateTime), N'Good', 3)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (1008, 1024, CAST(N'2024-01-08T15:42:15.263' AS DateTime), N'Nice!', 3)
INSERT [dbo].[Feedback] ([FeedbackID], [ReservationID], [Date], [Comment], [Rating]) VALUES (1009, 1025, CAST(N'2024-01-08T15:48:41.233' AS DateTime), N'Great service!', 4)
SET IDENTITY_INSERT [dbo].[Feedback] OFF
GO
SET IDENTITY_INSERT [dbo].[ParkingLot] ON 

INSERT [dbo].[ParkingLot] ([LotID], [SubID], [Capacity], [LotName]) VALUES (1, 1, 20, N'A')
INSERT [dbo].[ParkingLot] ([LotID], [SubID], [Capacity], [LotName]) VALUES (2, 2, 30, N'B')
INSERT [dbo].[ParkingLot] ([LotID], [SubID], [Capacity], [LotName]) VALUES (3, 3, 40, N'C')
SET IDENTITY_INSERT [dbo].[ParkingLot] OFF
GO
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (1, 1)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (2, 2)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (3, 3)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (4, 1)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (5, 1)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (6, 1)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (7, 1)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (8, 1)
INSERT [dbo].[ParkingSpace] ([SpaceID], [LotID]) VALUES (9, 1)
GO
SET IDENTITY_INSERT [dbo].[Reservation] ON 

INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (1, 3, N'LKB-999', 1, 1, CAST(N'2024-01-10' AS Date), CAST(N'09:30:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (2, 4, N'HLB-239', 2, 2, CAST(N'2024-01-11' AS Date), CAST(N'11:45:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (3, 5, N'JLM-529', 3, 3, CAST(N'2024-01-12' AS Date), CAST(N'13:15:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (4, 6, N'ABC-897', 3, 3, CAST(N'2024-01-13' AS Date), CAST(N'15:30:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (5, 7, N'DEI-358', 3, 3, CAST(N'2024-01-14' AS Date), CAST(N'17:45:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (9, 18, N'XYZ-238', 2, 3, CAST(N'1900-01-01' AS Date), CAST(N'00:00:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (13, 1, N'ABC-500', 1, 1, CAST(N'2024-01-07' AS Date), CAST(N'22:00:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (15, 3, N'TMN-123', 3, 4, CAST(N'2024-01-07' AS Date), CAST(N'22:53:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (17, 3, N'BBB-111', 3, 4, CAST(N'2024-01-07' AS Date), CAST(N'23:44:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (21, 2, N'FFF-500', 2, 3, CAST(N'2024-01-07' AS Date), CAST(N'23:52:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (23, 18, N'STO-621', 1, 7, CAST(N'2024-01-07' AS Date), CAST(N'23:58:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (24, 3, N'QRP-548', 1, 8, CAST(N'2024-01-08' AS Date), CAST(N'01:15:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (1024, 19, N'JOB-382', 3, 4, CAST(N'2024-01-08' AS Date), CAST(N'15:41:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (1025, 21, N'MXY-222', 1, 9, CAST(N'2024-01-08' AS Date), CAST(N'15:47:00' AS Time))
INSERT [dbo].[Reservation] ([ReservationID], [UserID], [VehiclePlate], [LotID], [SpaceID], [ParkDate], [ParkTime]) VALUES (1026, 3, N'QER-234', 2, 3, CAST(N'2024-01-08' AS Date), CAST(N'16:00:00' AS Time))
SET IDENTITY_INSERT [dbo].[Reservation] OFF
GO
SET IDENTITY_INSERT [dbo].[SubscriptionCategory] ON 

INSERT [dbo].[SubscriptionCategory] ([SubID], [SubCategory], [HourlyRate]) VALUES (1, N'Gold', CAST(25.00 AS Decimal(10, 2)))
INSERT [dbo].[SubscriptionCategory] ([SubID], [SubCategory], [HourlyRate]) VALUES (2, N'Silver', CAST(15.00 AS Decimal(10, 2)))
INSERT [dbo].[SubscriptionCategory] ([SubID], [SubCategory], [HourlyRate]) VALUES (3, N'Platinum', CAST(35.00 AS Decimal(10, 2)))
SET IDENTITY_INSERT [dbo].[SubscriptionCategory] OFF
GO
SET IDENTITY_INSERT [dbo].[Transaction] ON 

INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (2, 3, 1, CAST(N'11:45:00' AS Time), CAST(12.50 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (3, 4, 2, CAST(N'13:15:00' AS Time), CAST(18.75 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (4, 5, 3, CAST(N'15:30:00' AS Time), CAST(15.00 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (5, 6, 4, CAST(N'17:45:00' AS Time), CAST(10.50 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (6, 7, 5, CAST(N'19:00:00' AS Time), CAST(25.00 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (7, 18, 23, CAST(N'01:07:42.8966667' AS Time), CAST(200.00 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (8, 3, 24, CAST(N'05:18:06.7333333' AS Time), CAST(350.00 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (1008, 19, 1024, CAST(N'18:43:23.4700000' AS Time), CAST(-175.00 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (1009, 21, 1025, CAST(N'20:49:40.5966667' AS Time), CAST(-105.00 AS Decimal(10, 2)))
INSERT [dbo].[Transaction] ([TransactionID], [UserID], [ReservationID], [ExitTime], [TotalAmount]) VALUES (1010, 3, 1026, CAST(N'18:01:07.2433333' AS Time), CAST(-105.00 AS Decimal(10, 2)))
SET IDENTITY_INSERT [dbo].[Transaction] OFF
GO
SET IDENTITY_INSERT [dbo].[User] ON 

INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (1, N'Emad', N'Emad', N'Tariq', N'emad@gmail.com', N'abc', N'Admin')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (2, N'Sofia123', N'Sofia', N'Haider', N'sofia@gmail.com', N'sofia789', N'Admin')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (3, N'ahsan1', N'Ahsan', N'Naeem', N'Ahsan@gmail.com', N'ahsan789', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (4, N'SophieM', N'Sophie', N'Miller', N'sophie.miller@example.com', N'sophie123', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (5, N'RyanK', N'Ryan', N'Khan', N'ryan.khan@example.com', N'ryan456', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (6, N'EmmaC', N'Emma', N'Clark', N'emma.clark@example.com', N'emma789', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (7, N'LilyR', N'Lily', N'Roberts', N'lily.roberts@example.com', N'lily789', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (18, N'lily', N'Emily', N'Alexander', N'emily@gmail.com', N'emily123', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (19, N'uzi', N'Uzair', N'Faisal', N'uzi@gmail.com', N'uzi123', N'User')
INSERT [dbo].[User] ([UserID], [Username], [FirstName], [LastName], [Email], [Password], [Role]) VALUES (21, N'mango', N'Adeel', N'Sharif', N'mango@gmail.com', N'mango', N'User')
SET IDENTITY_INSERT [dbo].[User] OFF
GO
SET IDENTITY_INSERT [dbo].[Vehicle] ON 

INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (1, N'ABC123')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (2, N'XYZ789')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (3, N'DEF456')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (4, N'GHI789')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (5, N'JKL012')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (6, N'DEF567')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (7, N'LMN719')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (8, N'OKL451')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (9, N'MNB719')
INSERT [dbo].[Vehicle] ([VehicleID], [LicensePlate]) VALUES (10, N'ORF012')
SET IDENTITY_INSERT [dbo].[Vehicle] OFF
GO
INSERT [dbo].[VehicleOwner] ([VehicleID], [UserID]) VALUES (1, 3)
INSERT [dbo].[VehicleOwner] ([VehicleID], [UserID]) VALUES (2, 4)
INSERT [dbo].[VehicleOwner] ([VehicleID], [UserID]) VALUES (3, 5)
INSERT [dbo].[VehicleOwner] ([VehicleID], [UserID]) VALUES (4, 6)
INSERT [dbo].[VehicleOwner] ([VehicleID], [UserID]) VALUES (5, 7)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [unq_email]    Script Date: 1/9/2024 2:33:34 AM ******/
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [unq_email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [unq_username]    Script Date: 1/9/2024 2:33:34 AM ******/
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [unq_username] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservation] ([ReservationID])
GO
ALTER TABLE [dbo].[ParkingLot]  WITH CHECK ADD FOREIGN KEY([SubID])
REFERENCES [dbo].[SubscriptionCategory] ([SubID])
GO
ALTER TABLE [dbo].[ParkingSpace]  WITH CHECK ADD FOREIGN KEY([LotID])
REFERENCES [dbo].[ParkingLot] ([LotID])
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD FOREIGN KEY([LotID])
REFERENCES [dbo].[ParkingLot] ([LotID])
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD FOREIGN KEY([SpaceID])
REFERENCES [dbo].[ParkingSpace] ([SpaceID])
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD  CONSTRAINT [fk_userid] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [fk_userid]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservation] ([ReservationID])
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[VehicleOwner]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[VehicleOwner]  WITH CHECK ADD FOREIGN KEY([VehicleID])
REFERENCES [dbo].[Vehicle] ([VehicleID])
GO
ALTER TABLE [dbo].[Feedback]  WITH CHECK ADD CHECK  (([Rating]>=(1) AND [Rating]<=(5)))
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD CHECK  (([Role]='User' OR [Role]='Admin'))
GO
/****** Object:  StoredProcedure [dbo].[checkout]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE procedure [dbo].[checkout] 
	   @userid int,@resID int,@exithour int,@amount int
	   as
	   begin
	   insert into [transaction](UserID,ReservationID,ExitTime,TotalAmount) values (@userid,@resID,dateadd(hour,@exithour,getdate()),@amount)
	   end
GO
/****** Object:  StoredProcedure [dbo].[DeleteFeedback]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteFeedback]
    @FeedbackID INT
AS
BEGIN
    DELETE FROM Feedback
    WHERE FeedbackID = @FeedbackID
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteReservation]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteReservation]
    @ReservationID INT
AS
BEGIN
    DELETE FROM Reservation
    WHERE ReservationID = @ReservationID
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteUser]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteUser]
    @UserID INT
AS
BEGIN
    DELETE FROM [User]
    WHERE UserID = @UserID;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteVehicle]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteVehicle]
    @VehicleID INT
AS
BEGIN
    DELETE FROM Vehicle
    WHERE VehicleID = @VehicleID;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteVehicleOwner]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteVehicleOwner]
    @VehicleID INT,
    @UserID INT
AS
BEGIN
    DELETE FROM VehicleOwner
    WHERE VehicleID = @VehicleID AND UserID = @UserID;
END;
GO
/****** Object:  StoredProcedure [dbo].[InsertPS]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[InsertPS]
 @LotID int,
 @SpaceID int OUTPUT
 as
 begin

 select Top 1 @SpaceID=SpaceID from ParkingSpace
 where LotID=@LotID
 order by SpaceID desc;

 set @SpaceID=@SpaceID+1;
  print @SpaceID
 insert into ParkingSpace(SpaceID,LotID) values (@SpaceID,@LotID)
 return @SpaceID;
 end
GO
/****** Object:  StoredProcedure [dbo].[proc_Sign_up]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Sign_up]
    @username VARCHAR(50),
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(50),
    @Password VARCHAR(50),
    @usertype VARCHAR(20)
AS
BEGIN
   INSERT INTO [User] (Username, FirstName, LastName, Email, Password, Role)
    VALUES (@username, @FirstName, @LastName, @Email, @Password, @UserType);

END;
GO
/****** Object:  StoredProcedure [dbo].[requestParking]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[requestParking]
	   @uid int, @liscenceplate varchar(25), @lotid int ,@spaceid int
	   as
	   begin
	   insert into ParkingSpace(LotID,SpaceID)values(@lotid,@spaceid)
	   insert into Reservation (UserID,VehiclePlate,LotID,SpaceID,ParkDate,ParkTime) values (@uID,@liscenceplate,@lotid,@spaceid,getdate(),CONVERT(VARCHAR, getdate()))
	   end
GO
/****** Object:  StoredProcedure [dbo].[submitFeedback]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   create procedure [dbo].[submitFeedback]
	   @ResID int, @Comment varchar(50), @Rating int
	   as
	   begin
	   Insert into Feedback(ReservationID,Date,Comment,Rating) values (@ResID,getdate(),@Comment,@Rating)
	   end
GO
/****** Object:  StoredProcedure [dbo].[UpdateReservation]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateReservation]
    @ReservationID INT,
    @UserID INT,
    @VehiclePlate varchar(25),
    @LotID INT,
    @SpaceID INT,
    @ParkDate DATE,
    @ParkTime TIME
AS
BEGIN
    UPDATE Reservation
    SET UserID = @UserID,
        VehiclePlate = @VehiclePlate,
        LotID = @LotID,
        SpaceID = @SpaceID,
        ParkDate = @ParkDate,
        ParkTime = @ParkTime   WHERE ReservationID = @ReservationID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateSubscriptionCategory]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateSubscriptionCategory]
    @SubID INT,
    @SubCategory VARCHAR(25),
    @HourlyRate DECIMAL(10, 2)
AS
BEGIN
    UPDATE SubscriptionCategory
    SET SubCategory = @SubCategory,
        HourlyRate = @HourlyRate
    WHERE SubID = @SubID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateUser]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateUser]
    @UserID INT,
    @Username VARCHAR(50),
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(25),
    @Password VARCHAR(25),
    @Role VARCHAR(20)
AS
BEGIN
    UPDATE [User]
    SET Username = @Username,
        FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        Password = @Password,
        Role = @Role
    WHERE UserID = @UserID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateVehicle]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateVehicle]
    @VehicleID INT,
    @NewLicensePlate VARCHAR(20)
AS
BEGIN
    UPDATE Vehicle
    SET LicensePlate = @NewLicensePlate
    WHERE VehicleID = @VehicleID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateVehicleOwner]    Script Date: 1/9/2024 2:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateVehicleOwner]
    @VehicleID INT,
    @UserID INT,
    @NewVehicleID INT,
    @NewUserID INT
AS
BEGIN
    UPDATE VehicleOwner
    SET VehicleID = @NewVehicleID,
        UserID = @NewUserID
    WHERE VehicleID = @VehicleID AND UserID = @UserID;
END;
GO
USE [master]
GO
ALTER DATABASE [Parkingmanagment] SET  READ_WRITE 
GO
