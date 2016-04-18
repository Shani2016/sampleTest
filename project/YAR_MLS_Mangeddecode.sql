USE [YAR_MLS]
GO
/****** Object:  Table [dbo].[tbl_LOOKUP]    Script Date: 04/18/2016 06:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_LOOKUP](
	[LookupName] [varchar](max) NULL,
	[VisibleName] [varchar](max) NULL,
	[LongValue] [varchar](max) NULL,
	[ShortValue] [varchar](max) NULL,
	[Value] [varchar](max) NULL,
	[IsShow] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_ColumnMatch]    Script Date: 04/18/2016 06:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_ColumnMatch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemName] [varchar](max) NULL,
	[DataType] [varchar](max) NULL,
	[MaximumLength] [int] NULL,
	[LongName] [varchar](max) NULL,
	[PropertyType] [varchar](max) NULL,
	[LookupName] [varchar](max) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[sysjobhistory]    Script Date: 04/18/2016 06:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysjobhistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[instance_id] [int] NOT NULL,
	[job_id] [uniqueidentifier] NOT NULL,
	[step_id] [int] NOT NULL,
	[step_name] [sysname] NOT NULL,
	[sql_message_id] [int] NOT NULL,
	[sql_severity] [int] NOT NULL,
	[message] [nvarchar](4000) NULL,
	[run_status] [int] NOT NULL,
	[run_date] [int] NOT NULL,
	[run_time] [int] NOT NULL,
	[run_duration] [int] NOT NULL,
	[operator_id_emailed] [int] NOT NULL,
	[operator_id_netsent] [int] NOT NULL,
	[operator_id_paged] [int] NOT NULL,
	[retries_attempted] [int] NOT NULL,
	[server] [sysname] NOT NULL,
 CONSTRAINT [PK_sysjobhistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitSheduler]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[SplitSheduler](@PropIds varchar(MAX),@TimeStamp Varchar(Max),@Delimiter char(1))       
returns @temptable TABLE (Id varchar(MAX),Stamp Varchar(Max))       
as       
begin      
    declare @idx int
    declare @idx1 int      
    declare @slice varchar(8000)       
    declare @slice1 varchar(8000)
    
    select @idx = 1       
        if len(@PropIds)<1 or @PropIds is null return       

    while @idx!= 0       
    begin       
        set @idx = charindex(@Delimiter,@PropIds)
        set @idx1 = charindex(@Delimiter,@TimeStamp)       
        if  @idx!=0 and @idx1!=0
            begin   
               set @slice = left(@PropIds,@idx - 1)
               set @slice1 = left(@TimeStamp,@idx1 - 1)
            end          
        else
            begin       
               set @slice = @PropIds
               set @slice1 = @TimeStamp
            end

        if(len(@slice)>0) and (len(@slice1)>0)
            BEGIN            
     insert into @temptable(Id) 
         values(@slice)
     
     UPDATE @temptable
                       SET Stamp = @slice1
                     WHERE Id = @slice
            END           

        set @PropIds = right(@PropIds,len(@PropIds) - @idx)
        set @TimeStamp = right(@TimeStamp,len(@TimeStamp) - @idx1)    
        if len(@PropIds) = 0 and len(@TimeStamp) = 0 break
    END; 
return 
end;
GO
/****** Object:  StoredProcedure [dbo].[SearchOneTable]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SearchOneTable]-- '014900100','dbo.YAR_VIEW'

(
    @SearchStr nvarchar(100), --= 'A',
    @TableName nvarchar(256)  --= 'dbo.Alerts'
)
AS
BEGIN

    CREATE TABLE #Results (ColumnName nvarchar(370), ColumnValue nvarchar(3630))

    --SET NOCOUNT ON

    DECLARE @ColumnName nvarchar(128), @SearchStr2 nvarchar(110)
    SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''')
    --SET @SearchStr2 = QUOTENAME(@SearchStr, '''') --exact match
    SET @ColumnName = ' '


        WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
        BEGIN
            SET @ColumnName =
            (
                SELECT MIN(QUOTENAME(COLUMN_NAME))
                FROM    INFORMATION_SCHEMA.COLUMNS
                WHERE       TABLE_SCHEMA    = PARSENAME(@TableName, 2)
                    AND TABLE_NAME  = PARSENAME(@TableName, 1)
                    AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
                    AND QUOTENAME(COLUMN_NAME) > @ColumnName
            )

            IF @ColumnName IS NOT NULL
            BEGIN
                INSERT INTO #Results
                EXEC
                (
                    'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
                    FROM ' + @TableName + ' (NOLOCK) ' +
                    ' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
                )
            END
        END 
    SELECT ColumnName, ColumnValue FROM #Results
END
GO
/****** Object:  StoredProcedure [dbo].[SearchAllData]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SearchAllData]
(
    @SearchStr nvarchar(100) = 'A',
    @TableName nvarchar(256) = 'dbo.Alerts',
    @ColumnName nvarchar(256)=''
)
AS
Begin
if @ColumnName = '0'
begin 
  EXECUTE(
  'SELECT ''City'' as category,[L_City] as label,[L_City] as value,COUNT([L_City]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [L_City]) As RowNum FROM '+@TableName+' where [L_City] like ''%'+@SearchStr+'%'' AND [L_City] not like ''%,%'' group by [L_City]'
 -- +' union all SELECT ''Neighborhood'' as category,[LM_Char25_1] as label,[LM_Char25_1] as value,COUNT([LM_Char25_1]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [LM_Char25_1]) As RowNum FROM '+@TableName+' where [LM_Char25_1] like ''%'+@SearchStr+'%'' AND [LM_Char25_1] not like ''%,%'' group by [LM_Char25_1]'
 +' union all SELECT ''Address'' as category,REPLACE(([L_AddressNumber] +'' ''+ [L_AddressStreet]),'','','''') as label,REPLACE(([L_AddressNumber] +'' ''+ [L_AddressStreet]),'','','''') as value,COUNT([L_AddressNumber]+[L_AddressStreet]) as TotalCount,ROW_NUMBER() OVER (ORDER BY REPLACE(([L_AddressNumber] +'' ''+ [L_AddressStreet]),'','','''')) As RowNum FROM '+@TableName+'   where REPLACE(([L_AddressNumber] +'' ''+ [L_AddressStreet]),'','','''') like ''%'+@SearchStr+'%'' group by REPLACE(([L_AddressNumber] +'' ''+ [L_AddressStreet]),'','','''')'
  +' union all SELECT ''MLS Number'' as category,CONVERT(Varchar(50),[L_ListingID]) as label,CONVERT(Varchar(50),[L_ListingID]) as value,COUNT([L_ListingID]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [L_ListingID]) As RowNum FROM '+@TableName+' where [L_ListingID] like ''%'+@SearchStr+'%'' AND [L_ListingID] not like ''%,%'' group by [L_ListingID]'
 -- +' union all SELECT ''Address'' as category,[L_Address] as label,[L_Address] as value,COUNT([L_Address]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [L_Address]) As RowNum FROM '+@TableName+' where [L_Address] like ''%'+@SearchStr+'%'' AND [L_Address] not like ''%,%''  group by [L_Address]'
  --+' union all SELECT ''Middle School'' as category,[LIST_89] as label,[LIST_89] as value,COUNT([LIST_89]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [LIST_89]) As RowNum FROM '+@TableName+' where [LIST_89] like ''%'+@SearchStr+'%'' AND [LIST_89] not like ''%,%'' group by [LIST_89]'
  --+' union all SELECT ''Elementary School'' as category,[LIST_88] as label,[LIST_88] as value,COUNT([LIST_88]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [LIST_88]) As RowNum FROM '+@TableName+' where [LIST_88] like ''%'+@SearchStr+'%'' AND [LIST_88] not like ''%,%'' group by [LIST_88]'
  +' union all SELECT ''Zip Code'' as category,CONVERT(Varchar(50),[L_Zip]) as label,CONVERT(Varchar(50),[L_Zip]) as value,COUNT([L_Zip]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [L_Zip]) As RowNum FROM '+@TableName+' where [L_Zip] like ''%'+@SearchStr+'%'' AND [L_Zip] not like ''%,%'' group by [L_Zip]');
 -- +' union all SELECT ''County'' as category,[LIST_41] as label,[LIST_41] as value,COUNT([LIST_41]) as TotalCount,ROW_NUMBER() OVER (ORDER BY [LIST_41]) As RowNum FROM '+@TableName+' where [LIST_41] like ''%'+@SearchStr+'%'' AND [LIST_41] not like ''%,%'' group by [LIST_41]');
  End;
if @ColumnName = '1' 
begin 
  EXECUTE('SELECT ''City'' as category,[L_City] as label,COUNT([L_City]) as TotalCount FROM '+@TableName+' where [L_City] like ''%'+@SearchStr+'%'' AND [L_City] not like ''%,%''  group by [L_City]');
  End;
  if @ColumnName = '2' 
begin 
  EXECUTE('SELECT ''Neighborhood'' as category,[LM_Char25_1] as label,COUNT([LM_Char25_1]) as TotalCount FROM '+@TableName+' where [LM_Char25_1] like ''%'+@SearchStr+'%'' AND [LM_Char25_1] not like ''%,%'' group by [LM_Char25_1]');
  End;
   if @ColumnName = '3' 
begin 
  EXECUTE('SELECT ''Address'' as category,[216]+'' , ''+[215] as label,COUNT([216]+[215]) as TotalCount FROM '+@TableName+' where ( [216] like ''%'+@SearchStr+'%'' or [215] like ''%'+@SearchStr+'%'' ) AND [216] not like ''%,%'' AND [215] not like ''%,%'' group by [216],[215]');
  End;
  if @ColumnName = '4' 
begin 
  EXECUTE('SELECT ''MLS Number'' as category,CONVERT(Varchar(50),[L_ListingID]) as label,COUNT([L_ListingID]) as TotalCount FROM '+@TableName+' where [L_ListingID] like ''%'+@SearchStr+'%'' AND [L_ListingID] not like ''%,%'' group by [L_ListingID]');
  End;
  if @ColumnName = '5' 
begin 
  EXECUTE('SELECT ''High School'' as category,[L_Address] as label,COUNT([L_Address]) as TotalCount FROM '+@TableName+' where [L_Address] like ''%'+@SearchStr+'%'' AND [L_Address] not like ''%,%'' group by [L_Address]'
  +' union all SELECT ''Middle School'' as category,[LIST_89] as label,COUNT([LIST_89]) as TotalCount FROM '+@TableName+' where [LIST_89] like ''%'+@SearchStr+'%''  AND [LIST_89] not like ''%,%'' group by [LIST_89]'
  +' union all SELECT ''Elementary School'' as category,[LIST_88] as label,COUNT([LIST_88]) as TotalCount FROM '+@TableName+' where [LIST_88] like ''%'+@SearchStr+'%''  AND [LIST_88] not like ''%,%'' group by [LIST_88]');
  End;
  if @ColumnName = '6' 
begin 
  EXECUTE('SELECT ''PostalCode'' as category,CONVERT(Varchar(50),[L_Zip]) as label,COUNT([L_Zip]) as TotalCount FROM '+@TableName+' where [L_Zip] like ''%'+@SearchStr+'%''  AND [L_Zip] not like ''%,%'' group by [L_Zip]');
  End;
  if @ColumnName = '7' 
begin 
  EXECUTE('SELECT ''County'' as category,[LIST_41] as label,COUNT([LIST_41]) as TotalCount FROM '+@TableName+' where [LIST_41] like ''%'+@SearchStr+'%''  AND [LIST_41] not like ''%,%'' group by [LIST_41]');
End;
end;
GO
/****** Object:  Table [dbo].[A_lat_lon_YAR]    Script Date: 04/18/2016 06:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[A_lat_lon_YAR](
	[LatLanId] [int] IDENTITY(1,1) NOT NULL,
	[L_ListingID] [varchar](max) NULL,
	[latitude] [real] NULL,
	[longitude] [real] NULL,
	[addressfield] [nvarchar](300) NULL,
	[city_name] [varchar](100) NULL,
	[LatLanCreatedDate] [datetime] NULL,
 CONSTRAINT [PK_A_lat_lon_SWF] PRIMARY KEY CLUSTERED 
(
	[LatLanId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[Prc_CountAndResult]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prc_CountAndResult]
                 (
                  @StartIndex VARCHAR(Max) ,
                  @EndIndex VARCHAR(Max),
                  @ColumnNames Varchar(Max),
                  @TableName Varchar(Max),
                  @Condition Varchar(Max),
                  @IsOfficeListing bit,
                  @IsMemberListing bit,
                  @OfficeIds varchar(max),
                  @MemberOfficeIds varchar(max),
                  @OrderByColumn varchar(max),
                  @Direction varchar(max), --ASC or DESC
                  @OnlyCount bit,
                  @IsNewListing bit
                 )
AS
BEGIN

	IF @OnlyCount = 0 
	Begin	
      DECLARE @SqlCountString AS Varchar(Max),
              @SqlFinalString AS VArchar(Max);
              
               IF  @StartIndex <> 0 and @EndIndex <> 0
               Begin
                    SET @SqlFinalString =' SELECT * '
				                        +' FROM ' 
				                        +'    ( '
				                        +'      SELECT ROW_NUMBER () OVER (ORDER BY (SELECT 1)) AS ''Rank'', *  ' 
		                                +'        FROM '
			                            +'           ( '
			                IF @IsNewListing<>0
			        Begin
			         SET @SqlFinalString +=' SELECT Row_Number() OVER ('    
											    +' ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
                           						+' FROM '+ @TableName+' '+ @Condition
			        end        
			                
			        else
			        begin                 
			        IF  @IsOfficeListing <> 0
				   	Begin
				   	
				   	        If  @IsMemberListing <> 0
							Begin
											      
							     SET @SqlFinalString +=' select Row_Number() OVER (ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
                  + ' FROM '+ @TableName+' where L_ListAgent2 in ('+@MemberOfficeIds+') and [L_Status] not in(''Hold-Do Not Show'')'
												  	 +' union all '
												  	 +' select Row_Number() OVER (ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
												  	 + ' FROM '+ @TableName+' where OfficeID in ('+@OfficeIds+') and [L_Status] not in(''Hold-Do Not Show'')'
												  	 +' union all '
												  	 +' SELECT Row_Number() OVER (ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
												  	 +' FROM '+ @TableName+' '+ @Condition +' and OfficeID not in ('+@OfficeIds+') and L_ListAgent2 not in ('+@MemberOfficeIds+') '
							End--IsMemberListing End
				   	        Else
				   	        Begin
						       SET @SqlFinalString +=' select Row_Number() OVER (ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
											       + ' FROM '+ @TableName+' where OfficeID in ('+@OfficeIds+') and [L_Status] not in(''Hold-Do Not Show'')'
											       +' union all '
											       +' SELECT Row_Number() OVER (ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
											       +' FROM '+ @TableName+' '+ @Condition +' and OfficeID not in ('+@OfficeIds+') '
			                End								  
					End--ISOfficeListing End
					Else
					Begin
					
 						     SET @SqlFinalString +=' SELECT Row_Number() OVER (PARTITION BY CASE WHEN L_ListAgent2 in ('+@MemberOfficeIds+') THEN 0 WHEN OfficeID in ('+@OfficeIds+') Then 1 ELSE 2 END '       
											    +' ORDER BY '+@OrderByColumn+' '+@Direction+ ' ) as RowsNo, '+@ColumnNames
                           						+' FROM '+ @TableName+' '+ @Condition
					End
				end	
			  	          SET @SqlFinalString +='  )XX ' 
									          +'     )as All_Properties_orlando '
									          +' WHERE All_Properties_orlando.Rank between '+@StartIndex+' AND '+@EndIndex
		                           			
                                
                          --SELECT @SqlFinalString                    
                End--start index snd end index
			    Else
			    Begin
					 SET @SqlFinalString ='SELECT '+ @ColumnNames 
										 +' FROM '+ @TableName+' '+ @Condition 
										 +' Order by '+ @OrderByColumn +' '+@Direction;
		                                  
					--SELECT @SqlFinalString
			   End
      
                      EXEC (@SqlFinalString)
      End --Only Count End 
    
         SET @SqlCountString =' SELECT COUNT(L_ListingID) TotalCount ' 
                             +'  FROM '+ @TableName +' '+  @Condition ;
                                 
          --SELECT @SqlFinalString 
         
         EXEC (@SqlCountString)
END;--Sp End
GO
/****** Object:  UserDefinedFunction [dbo].[MakeFristCharecter_UpperCase]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MakeFristCharecter_UpperCase]
(
   @Expr NVARCHAR(MAX),@SetToLowerCaseFirst BIT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Result NVARCHAR(MAX)
       IF @Expr is not null
       
		  BEGIN
			DECLARE @Position INT,
					@Capitalize BIT,
					@Char NCHAR(1)
			 SELECT @Result=CASE
			                    WHEN @SetToLowerCaseFirst=1 THEN Lower(@Expr)ELSE @Expr
			                 END,
			        @Position=0,
			        @Capitalize=1
			  WHILE @Position<len(@Result)
				
			  BEGIN
				  
				  SELECT @Position=@Position+1,@Char=substring(@Result,@Position,1)
			          
					  IF @Capitalize=1
				  SELECT @Capitalize=0,@Result=stuff(@Result,@Position,1,upper(@Char))
				  
					  IF charindex(@Char,' #%&*()-_=+[]{}":./')>0 
					 SET @Capitalize=1
					  
				END
		  END
  RETURN @Result
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fun_YAR_View_SplitPropertyType]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fun_YAR_View_SplitPropertyType](@String VARCHAR(MAX), @Delimiter CHAR(1))       
RETURNS @temptable TABLE (items VARCHAR(MAX))       
AS       
BEGIN      
    DECLARE @idx INT       
    DECLARE @slice VARCHAR(8000)       

    SELECT @idx = 1       
        IF LEN(@String)<1 OR @String IS NULL  RETURN       

    WHILE @idx!= 0       
    BEGIN       
        SET @idx = CHARINDEX(@Delimiter,@String)       
        IF @idx!=0       
            SET @slice = LEFT(@String,@idx - 1)       
        ELSE       
            SET @slice = @String       

        IF(LEN(@slice)>0)  
            INSERT INTO @temptable(Items) VALUES(@slice)       

        SET @String = RIGHT(@String,LEN(@String) - @idx)       
        IF LEN(@String) = 0 BREAK       
    END   
RETURN 
END;
GO
/****** Object:  UserDefinedFunction [dbo].[Fun_YAR_SplitTableName]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fun_YAR_SplitTableName](@String VARCHAR(MAX), @Delimiter CHAR(1))       
RETURNS @temptable TABLE (items VARCHAR(MAX))       
AS       
BEGIN      
    DECLARE @idx INT       
    DECLARE @slice VARCHAR(8000)       

    SELECT @idx = 1       
        IF LEN(@String)<1 OR @String IS NULL  RETURN       

    WHILE @idx!= 0       
    BEGIN       
        SET @idx = CHARINDEX(@Delimiter,@String)       
        IF @idx!=0       
            SET @slice = LEFT(@String,@idx - 1)       
        ELSE       
            SET @slice = @String       

        IF(LEN(@slice)>0)  
            INSERT INTO @temptable(Items) VALUES(@slice)       

        SET @String = RIGHT(@String,LEN(@String) - @idx)       
        IF LEN(@String) = 0 BREAK       
    END   
RETURN 
END;
GO
/****** Object:  UserDefinedFunction [dbo].[Fun_YAR_SplitExecuteScheduler]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fun_YAR_SplitExecuteScheduler](@String VARCHAR(MAX),@String1 AS Varchar(Max), @Delimiter CHAR(1))       
RETURNS @temptable TABLE (Col1 VARCHAR(MAX), Col2 Varchar(Max))       
AS       
BEGIN      
    DECLARE @idx INT
    DECLARE @idx1 INT       
    DECLARE @slice VARCHAR(8000)
    DECLARE @slice1 VARCHAR(8000)     

    SELECT @idx = 1       
        IF LEN(@String)<1 OR @String IS NULL  RETURN
    SELECT @idx1 = 1        
        IF LEN(@String1)<1 OR @String1 IS NULL  RETURN 
        
    WHILE @idx!= 0 AND @idx1 !=0     
    BEGIN 
          
        SET @idx = CHARINDEX(@Delimiter,@String)
        SET @idx1 = CHARINDEX(@Delimiter,@String1)     
        IF @idx!=0 AND @idx1!=0
          BEGIN       
            SET @slice = LEFT(@String,@idx - 1)
            SET @slice1 = LEFT(@String1,@idx1 - 1)       
          END;
        ELSE 
          BEGIN      
            SET @slice = @String
            SET @slice1 = @String1         
          END
        IF(LEN(@slice)>0) AND (LEN(@slice1)>0) 
            INSERT INTO @temptable(Col1,Col2) VALUES(@slice,@slice1)       

        SET @String = RIGHT(@String,LEN(@String) - @idx)
        SET @String1 = RIGHT(@String1,LEN(@String1) - @idx1)      
        IF LEN(@String) = 0 BREAK
    END   
RETURN 
END;
GO
/****** Object:  UserDefinedFunction [dbo].[Fun_YAR_SplitColumn]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fun_YAR_SplitColumn](@String VARCHAR(MAX), @Delimiter CHAR(1))       
RETURNS @temptable TABLE (items VARCHAR(MAX))       
AS       
BEGIN      
    DECLARE @idx INT       
    DECLARE @slice VARCHAR(8000)       

    SELECT @idx = 1       
        IF LEN(@String)<1 OR @String IS NULL  RETURN       

    WHILE @idx!= 0       
    BEGIN       
        SET @idx = CHARINDEX(@Delimiter,@String)       
        IF @idx!=0       
            SET @slice = LEFT(@String,@idx - 1)       
        ELSE       
            SET @slice = @String       

        IF(LEN(@slice)>0)  
            INSERT INTO @temptable(Items) VALUES(@slice)       

        SET @String = RIGHT(@String,LEN(@String) - @idx)       
        IF LEN(@String) = 0 BREAK       
    END   
RETURN 
END;
GO
/****** Object:  UserDefinedFunction [dbo].[Fun_YAR_Split_TableName_Path Name]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[Fun_YAR_Split_TableName_Path Name](@String VARCHAR(MAX),@String1 AS Varchar(Max), @Delimiter CHAR(1))       
RETURNS @temptable TABLE (Col1 VARCHAR(MAX), Col2 Varchar(Max))       
AS       
BEGIN      
    DECLARE @idx INT
    DECLARE @idx1 INT       
    DECLARE @slice VARCHAR(8000)
    DECLARE @slice1 VARCHAR(8000)     

    SELECT @idx = 1       
        IF LEN(@String)<1 OR @String IS NULL  RETURN
    SELECT @idx1 = 1        
        IF LEN(@String1)<1 OR @String1 IS NULL  RETURN 
        
    WHILE @idx!= 0 AND @idx1 !=0     
    BEGIN 
          
        SET @idx = CHARINDEX(@Delimiter,@String)
        SET @idx1 = CHARINDEX(@Delimiter,@String1)     
        IF @idx!=0 AND @idx1!=0
          BEGIN       
            SET @slice = LEFT(@String,@idx - 1)
            SET @slice1 = LEFT(@String1,@idx1 - 1)       
          END;
        ELSE 
          BEGIN      
            SET @slice = @String
            SET @slice1 = @String1         
          END
        IF(LEN(@slice)>0) AND (LEN(@slice1)>0) 
            INSERT INTO @temptable(Col1,Col2) VALUES(@slice,@slice1)       

        SET @String = RIGHT(@String,LEN(@String) - @idx)
        SET @String1 = RIGHT(@String1,LEN(@String1) - @idx1)      
        IF LEN(@String) = 0 BREAK
    END   
RETURN 
END;
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GenerateRandomNumber]    Script Date: 04/18/2016 06:21:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GenerateRandomNumber]()
RETURNS INT
AS
BEGIN
 DECLARE @RandomNumber   INT

 SELECT @RandomNumber = ABS(CAST(CAST([RandomID] AS VARBINARY) AS INT))
 FROM [dbo].[Random]

 RETURN @RandomNumber
END

--SELECT [dbo].[ufn_GenerateRandomNumber]()
GO
/****** Object:  StoredProcedure [dbo].[prc_YAR_Scheduler]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[prc_YAR_Scheduler] --'COM','C:\HVMLS',NULL
                 (
                  @TableName VARCHAR (MAX),                  
                  @DataFilePath Varchar(Max)
                 )
AS
BEGIN
-----------------------------------------------------------------------------
-----//Fetching Column List From .TXT File
-----------------------------------------------------------------------------
DECLARE @BulkSQL1 AS VARCHAR (MAX),
        @BulkSql2 AS VARCHAR (MAX);
        
SET @BulkSQL1 = '      
                       IF OBJECT_ID(''Tempdb..YAR_BulkColumnString'') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_BulkColumnString
                       CREATE TABLE Tempdb.dbo.YAR_BulkColumnString  (ColumnString Varchar(MAX));
                       
                       DECLARE @BulkString1 AS VARCHAR(MAX),
                               @BulkString2 AS VARCHAR(MAX);
                       
                       BULK INSERT Tempdb.dbo.YAR_BulkColumnString
                       FROM ''{Path}.txt''
                       WITH (
                             FIRSTROW = 1,
                             LASTROW = 1,
                             ROWTERMINATOR = ''\n''
                            )
                       
                       SET @BulkString1 = (SELECT ColumnString FROM Tempdb.dbo.YAR_BulkColumnString)
                       SET @BulkString2 = REPLACE(@BulkString1,''	'',''|'')
                       
                       TRUNCATE TABLE Tempdb.dbo.YAR_BulkColumnString
                       
                       INSERT INTO Tempdb.dbo.YAR_BulkColumnString (ColumnString)
                                                        VALUES (@BulkString2)
                         
                  '



    SET @BulkSql2 = REPLACE(@BulkSQL1,'{Path}',@DataFilePath)
    EXEC (@BulkSql2)
    
    --SELECT ColumnString FROM Tempdb.dbo.BulkColumnString
-----------------------------------------------------------------------------
-----//Shows List Of Column Names Fetch From .TXT FILE
-----------------------------------------------------------------------------
    --SELECT Items AS 'Column Names From Txt File'
    --  FROM [dbo].[Fun_YAR_SplitColumn]((SELECT ColumnString FROM Tempdb.dbo.YAR_BulkColumnString),'|') 
-----------------------------------------------------------------------------
-----//Declare Cursor
-----//Create Table From Records Of "ColumnMatch" Table
-----------------------------------------------------------------------------
DECLARE @SQLString1 Varchar(Max),
        @SQLString2 Varchar (Max),
        @FinalSQLString VARCHAR (Max),
        @Condition Varchar (Max),
        @Tbl_Name Varchar(Max);
        
    SET @Condition = @TableName
    SET @Tbl_Name = REPLACE(@TableName,' ','')
         
  SET @SQLString1 =  
   '
    IF OBJECT_ID(''New_tbl_{Name}'') IS NOT NULL DROP TABLE New_tbl_{Name};
    CREATE TABLE New_tbl_{Name} (HVId INT );    
    
    DECLARE @Item AS VARCHAR(MAX),
            @ColumnName AS VARCHAR(MAX);
             
        
    DECLARE @CursorColumnFetch CURSOR
	    SET @CursorColumnFetch = CURSOR FAST_FORWARD
        FOR
		         SELECT REPLACE(Items,'' '','''')
                   FROM [dbo].[Fun_YAR_SplitColumn]((SELECT ColumnString FROM Tempdb.dbo.YAR_BulkColumnString),''|'') 
		          
       OPEN @CursorColumnFetch
		         FETCH NEXT FROM @CursorColumnFetch
		          INTO @Item
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
             SET @ColumnName = @Item
    
     DECLARE @SystemName Varchar(Max),
             @DataType Varchar(Max),
             @MaximumLength Varchar(MAX),
             @PropertyType Varchar(MAX),
             @SqlQuery Varchar(Max);                 
                       
	DECLARE @CursorColumnMatchXml CURSOR
	    SET @CursorColumnMatchXml = CURSOR FAST_FORWARD
        FOR
		         SELECT SystemName,DataType,MaximumLength,PropertyType 
		           FROM Tempdb.dbo.YAR_ColumnMatch
		          WHERE PropertyType = ''{[Condition]}''
		            AND SystemName = @ColumnName 
		        --ORDER BY PropertyType
		          
       OPEN @CursorColumnMatchXml
		         FETCH NEXT FROM @CursorColumnMatchXml
		          INTO @SystemName,@DataType,@MaximumLength,@PropertyType
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
	
          SET @DataType= ( SELECT
							 CASE @DataType
								  WHEN ''Character'' THEN '' VARCHAR(MAX)''
								  WHEN ''DateTime''  THEN '' datetime ''
								  WHEN ''Int''       THEN '' VARCHAR(MAX) ''
								  WHEN ''Date''      THEN '' datetime ''
								  WHEN ''Decimal''   THEN '' Decimal(18,6) ''
								  WHEN ''Boolean''   THEN '' bit ''
								  WHEN ''real''      THEN '' real ''
								  WHEN ''Long''      THEN '' bigint ''
								  WHEN ''Small''     THEN '' VARCHAR(MAX) ''
								  WHEN ''Tiny''      THEN '' tinyint ''
							 END)
            
            IF ( @SystemName = ''L_LastDocUpdate'' OR @SystemName = ''L_Keyword9'' OR @SystemName = ''L_Keyword8 '' OR @SystemName = ''L_Keyword7'' OR @SystemName = ''L_Keyword5''OR @SystemName = ''L_Keyword4'' OR @SystemName = ''L_Keyword3'' OR @SystemName = ''L_Keyword2'' OR @SystemName = ''L_Keyword1'' or @SystemName = ''1092'' OR @SystemName = ''154'' OR @SystemName = ''1398'' OR @SystemName = ''7'' OR @SystemName = ''Photolocation'' OR @SystemName = ''LFD_MasterBath_95'' OR @SystemName = ''LFD_Parking_16'' OR @SystemName = ''LFD_PropDescription_20''OR @SystemName = ''LFD_SquareFootageRange_4''OR @SystemName = ''L_Keyword6'' OR @SystemName = ''LFD_Livingroom_96''OR @SystemName = ''LFD_Cooling_108''OR @SystemName = ''LFD_Utilities_109'' OR @SystemName = ''LFD_DinningRoomArea_97'' OR @SystemName = ''LFD_Kitchen_98'' OR @SystemName = ''LFD_ToShow_124'' OR @SystemName = ''LFD_Foundation_110'' OR @SystemName = ''LFD_KitchenFeatures_99'')
            BEGIN
            
                  SET @SqlQuery= ''ALTER TABLE New_tbl_{Name}
                                     ADD [''+@SystemName+'']''+ '' VARCHAR(MAX)''+'' ;''
            
              END;
           ELSE
            BEGIN
            
				  SET @SqlQuery= ''ALTER TABLE New_tbl_{Name}
                                     ADD [''+@SystemName+'']''+@DataType+'' ;''
            
              END;
             IF ( @SystemName = ''L_AskingPrice'' OR @SystemName = ''L_SquareFeet'' OR @SystemName = ''1398'' )
            BEGIN
            
                  SET @SqlQuery= ''ALTER TABLE New_tbl_{Name}
                                     ADD [''+@SystemName+'']''+ '' INT''+'' ;''
            
              END;
                
            EXEC(@SqlQuery);
                		    
		     FETCH NEXT FROM @CursorColumnMatchXml
			  INTO @SystemName,@DataType,@MaximumLength,@PropertyType
			  
        END 
             CLOSE @CursorColumnMatchXml                           
        DEALLOCATE @CursorColumnMatchXml                     
     
                		    
		     FETCH NEXT FROM @CursorColumnFetch
			  INTO @Item
			  
        END
             CLOSE @CursorColumnFetch                           
        DEALLOCATE @CursorColumnFetch
        
        ALTER TABLE New_tbl_{Name} DROP COLUMN HVId;
        
    
    '

SET @SQLString2 = REPLACE(@SQLString1,'{[Condition]}',@Condition)
SET @FinalSQLString = REPLACE(@SQLString2,'{Name}',@Tbl_Name)
EXEC (@FinalSQLString)

SET @BulkSQL1 = 
               '
                BULK INSERT New_tbl_{Name}
                FROM ''{Path}.txt''
                WITH (
                      FIELDTERMINATOR =''	'',
                      rowterminator = ''\n'',
                      Firstrow = 2
                     )
               '
    SET @BulkSql2 = REPLACE(@BulkSQL1,'{Name}',@Tbl_Name)
    SET @FinalSQLString = REPLACE(@BulkSql2,'{Path}',@DataFilePath)
    EXEC(@FinalSQLString);
END;
GO
/****** Object:  StoredProcedure [dbo].[prc_property_search]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[prc_property_search]  
 -- Add the parameters for the stored procedure here
 @tablename varchar(max) 
 --@searchcriteria varchar(50)
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
 SET NOCOUNT ON;

    -- Insert statements for procedure here
 --SELECT * from @tablename where @searchcriteria
 exec (@tablename)
END
GO
/****** Object:  StoredProcedure [dbo].[Prc_InsertPhotoLocation]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prc_InsertPhotoLocation]
AS
BEGIN

INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
                                        VALUES ('Photolocation','char',8000,'Photo location','CI_3','')

INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
                                        VALUES ('Photolocation','char',8000,'Photo location','LD_2','')
                                        
INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
                                        VALUES ('Photolocation','char',8000,'Photo location','MF_4','')

INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
                                        VALUES ('Photolocation','char',8000,'Photo location','RE_1','')
                                        
INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
                                        VALUES ('Photolocation','char',8000,'Photo location','BU_5','')
                                        
INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
										VALUES ('Photolocation','char',8000,'Photo location','RN_6','')

INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
										VALUES ('Photolocation','char',8000,'Photo location','ActiveAgent','')

INSERT INTO Tempdb..YAR_ColumnMatch ([SystemName],[DataType],[MaximumLength],[LongName],[PropertyType],[LookupName])
										VALUES ('Photolocation','char',8000,'Photo location','ActiveOffice','')

                                        
END
GO
/****** Object:  StoredProcedure [dbo].[prc_InsertLOOKUP]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[prc_InsertLOOKUP]
AS
BEGIN
        TRUNCATE TABLE tbl_LOOKUP;
        
    --    EXEC Prc_InsertPhotoLocation
        
        INSERT INTO tbl_LOOKUP(LookupName,VisibleName,LongValue,ShortValue,Value)
		                     SELECT LookupName,VisibleName,LongValue,ShortValue,Value 
		    	               FROM Tempdb..YAR_LOOKUP

END
GO
/****** Object:  StoredProcedure [dbo].[prc_InsertColumnMatch]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[prc_InsertColumnMatch]
AS
BEGIN
        TRUNCATE TABLE tbl_ColumnMatch;
        
        EXEC Prc_InsertPhotoLocation
        
        INSERT INTO tbl_ColumnMatch(SystemName,DataType,MaximumLength,LongName,PropertyType,LookupName)
		                     SELECT DISTINCT SystemName,DataType,MaximumLength,LongName,PropertyType,LookupName 
		    	               FROM Tempdb..YAR_ColumnMatch

END
GO
/****** Object:  StoredProcedure [dbo].[Prc_Get_FavRatVwdProp]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prc_Get_FavRatVwdProp] 
	 @Handle varchar(Max),
	 @XmlPath varchar(max)
AS
BEGIN
	SET NOCOUNT ON; 
	    
        If(@XmlPath is not null)
		Begin
				IF OBJECT_ID('tbl_CreateXMLDoc') IS NOT NULL DROP TABLE tbl_CreateXMLDoc
				CREATE TABLE tbl_CreateXMLDoc
				(
					Id INT IDENTITY PRIMARY KEY,
					XMLData XML,
					LoadedDateTime DATETIME
				)

					DECLARE @sqlqury_1 AS Varchar(Max),
					@sqlqury_2 As Varchar(Max)
					SET @sqlqury_1 = 'INSERT INTO tbl_CreateXMLDoc(XMLData, LoadedDateTime)
					SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE()
					FROM OPENROWSET(BULK ''{Path}'', SINGLE_BLOB) AS x;'
					SET @sqlqury_2 = REPLACE(@sqlqury_1,'{Path}',@XmlPath)

					EXEC (@sqlqury_2)

					DECLARE @XML AS XML, @handleDoc AS INT, @SQL NVARCHAR (MAX)
					SELECT @XML = XMLData FROM tbl_CreateXMLDoc
					EXEC sp_xml_preparedocument @handleDoc OUTPUT, @XML
			
			--Create temprory table
			IF OBJECT_ID('tbl_DataVwdFavRat') IS Not NULL DROP TABLE tbl_DataVwdFavRat
	        Begin 
				CREATE TABLE tbl_DataVwdFavRat
				(
				     ListId Varchar(MAX),
					 MLSId Varchar(MAX),
					 FullBaths int,
					 HalfBaths int,
					 TotalBaths varchar(max),
					 TotalBeds int,
					 Address Varchar(MAX),
					 StreetNumber Varchar(MAX),
					 StreetName Varchar(MAX),
					 StreetSuffix Varchar(MAX),
					 City Varchar(MAX),
					 County Varchar(MAX),
					 State Varchar(MAX),
					 SubDivision Varchar(MAX),
					 ZipCode Varchar(MAX),
					 Price real,
					 Sqft real,
					 Pricepersqft real,
					 Acre varchar(MAX),
					 PropertyType Varchar(MAX),
					 Status Varchar(MAX),
					 OfficeName Varchar(MAX),
					 photoUrl Varchar(MAX),
					 WaterFront bit default(0),
					 Shortsale bit default(0),
					 Foreclosure bit default(0),
					 IsOpenHouse bit default(0),
					 OpenHouseBegins Varchar(MAX),
					 OpenHouseClose Varchar(MAX),
					 PriceChangedDate Varchar(MAX),
					 LastModifiedDate Varchar(MAX),
					 YearBuilt Varchar(MAX),
					 PublicRemark Varchar(MAX),
					 
					 --not updated this  field if ListID is matched 
					 PropertySubType varchar(MAX),
					 Area varchar(MAX),
					 Neighbourhood varchar(MAX),
					 DateViewedFavRat varchar(MAX),
					 ImagePath_FromXML varchar(MAX),
					 ViewedTotalCount int,
					 RatingCount int,
					 
                     OffMarket bit default(1),
                     ActivityType varchar(50)
				)
			End 
        End

		IF(@Handle='ViewedFavRat')
		Begin
		----Insert viewed property
				INSERT INTO tbl_DataVwdFavRat (
				    ListId,
					MLSId,
					PropertyType,
					PropertySubType,
					Price,
					City,
					State,
					ZipCode,
					TotalBeds,
					FullBaths,
					Sqft,
					Neighbourhood,
					Area,
					DateViewedFavRat,
					ViewedTotalCount,
					ImagePath_FromXML,
					ActivityType
					)
				SELECT 
					ListId,
					MLSId,
					PropertyType,
					PropertySubType,
					Price,
					City,
					State,
					ZipCode,
					TotalBeds,
					FullBaths,
					Sqft,
					Neighbourhood,
					Area,
					DateViewedFavRat,
					ViewedTotalCount,
					ImagePath_FromXML,
					'Vwd'
				FROM OPENXML(@handleDoc, '//Activities/Years/Month/Day/Session/Property')
				WITH
					( 
					   
					ListId varchar(MAX) 'Viewed_ListingID',
					MLSId varchar(MAX) 'MLS',
					PropertyType varchar(MAX) 'Viewed_PropertyType',
					PropertySubType varchar(MAX) 'Viewed_Property_SubType',
					Price real 'Viewed_Price',
					City varchar(MAX) 'Viewed_City',
					State varchar(MAX) 'Viewed_State',
					ZipCode varchar(MAX) 'Viewed_Zipcode',
					TotalBeds int 'Viewed_Beds',
					FullBaths int 'Viewed_Baths',
					Sqft real 'Viewed_Sqft',
					Neighbourhood varchar(MAX) 'Viewed_Neighbourhood',
					Area varchar(MAX) 'Viewed_Area',
					DateViewedFavRat varchar(MAX) 'Viewed_DateViewed',
					ViewedTotalCount int 'TotalCount',
					ImagePath_FromXML varchar(MAX) 'Viewed_ImagePath'
					) as X

		--Insert Fav property

				INSERT INTO tbl_DataVwdFavRat (
				    ListId,
					MLSId,
					PropertyType,
					PropertySubType,
					Price,
					City,
					State,
					ZipCode,
					TotalBeds,
					FullBaths,
					Sqft,
					Neighbourhood,
					Area,
					DateViewedFavRat,
					ImagePath_FromXML,
					ActivityType
					)
				SELECT 
					ListId,
					MLSId,
					PropertyType,
					PropertySubType,
					Price,
					City,
					State,
					ZipCode,
					TotalBeds,
					FullBaths,
					Sqft,
					Neighbourhood,
					Area,
					DateViewedFavRat,
					ImagePath_FromXML,
					'Fav'
				FROM OPENXML(@handleDoc, '//Activities/Favoirate/Fav_property')
				WITH
				( 
				    ListId varchar(MAX) 'Fav_property_ListingID',
					MLSId varchar(MAX) 'Fav_MLS',
					PropertyType varchar(MAX) 'Fav_PropertyType',
					PropertySubType varchar(MAX) 'Fav_Property_SubType',
					Price real 'Fav_property_Price',
					City varchar(MAX) 'Fav_property_City',
					State varchar(MAX) 'Fav_State',
					ZipCode varchar(MAX) 'Fav_property_Zipcode',
					TotalBeds int 'Fav_property_Beds',
					FullBaths int 'Fav_property_Baths',
					Sqft real 'Fav_property_Sqft',
					Neighbourhood varchar(MAX) 'Fav_property_Neighbourhood',
					Area varchar(MAX) 'Fav_property_Area',
					DateViewedFavRat varchar(MAX) 'Fav_Date',
					ImagePath_FromXML varchar(MAX) 'Fav_ImagePath'
				) as X

		
		----Insert rating property

				INSERT INTO tbl_DataVwdFavRat (
				    ListId,
					MLSId,
					PropertyType,
					PropertySubType,
					Price,
					City,
					State,
					ZipCode,
					TotalBeds,
					FullBaths,
					Sqft,
					Neighbourhood,
					Area,
					DateViewedFavRat,
					ImagePath_FromXML,
					RatingCount,
					ActivityType
					)
				SELECT 
					ListId,
					MLSId,
					PropertyType,
					PropertySubType,
					Price,
					City,
					State,
					ZipCode,
					TotalBeds,
					FullBaths,
					Sqft,
					Neighbourhood,
					Area,
					DateViewedFavRat,
					ImagePath_FromXML,
					RatingCount,
					'Rat'
					
				FROM OPENXML(@handleDoc, '//Activities/RatingPropList/Rating_property')
				WITH
				( 
				
				    ListId varchar(MAX) 'Rating_property_ListingID',
					MLSId varchar(MAX) 'Rating_MLS',
					PropertyType varchar(MAX) 'Rating_PropertyType',
					PropertySubType varchar(MAX) 'Rating_Property_SubType',
					Price real 'Rating_property_Price',
					City varchar(MAX) 'Rating_property_City',
					State varchar(MAX) 'Rating_State',
					ZipCode varchar(MAX) 'Rating_property_Zipcode',
					TotalBeds int 'Rating_property_Beds',
					FullBaths int 'Rating_property_Baths',
					Sqft real 'Rating_property_Sqft',
					Neighbourhood varchar(MAX) 'Rating_property_Neighbourhood',
					Area varchar(MAX) 'Rating_property_Area',
					DateViewedFavRat varchar(MAX) 'Rating_Date',
					ImagePath_FromXML varchar(MAX) 'Rating_ImagePath',
					RatingCount int 'Rating_RatingCount'
					
				) as X
			
		END
        EXEC sp_xml_removedocument @handleDoc

	   --delete duplicate listing 
	   --;WITH tmpResult AS
		--(
		-- SELECT*, ROW_NUMBER()OVER (PARTITION BY ListingID ORDER BY ListingID) AS ROW_NO from tbl_DataVwdFavRat
		--)
		--DELETE FROM tmpResult WHERE ROW_NO > 1;
		  
		  	
			                       		--check matched record on listingID and update off market flag to 0 cause by default colom value 1
			                       		--Its actual opposite handle here		
										MERGE tbl_DataVwdFavRat AS T
										USING (SELECT L_ListingID FROM YAR_VIEW) AS S
										ON T.ListId = S.L_ListingID
										WHEN MATCHED  THEN 
										UPDATE SET T.OffMarket = 0;
									
										--check matched record on listingID and update matched record from mls table
										MERGE tbl_DataVwdFavRat AS T
										USING (SELECT L_ListingID,Full_Bath,Total_Beds,L_AddressNumber,L_AddressStreet,
										              L_City,L_State,L_Zip,L_AskingPrice,L_SquareFeet,ACRES,Photolocation,--LFD_WaterFrontageType_66,
										              L_Type_,L_Status,L_Remarks,
										              LM_Int4_1 ,officename
										           FROM YAR_VIEW) AS S
										ON T.ListId = S.L_ListingID
					                    WHEN MATCHED THEN
									    Update
									    SET  T.ListId =S.L_ListingID,
											 T.MLSId =S.L_ListingID,
											 T.FullBaths =S.Full_Bath,
										--	 T.HalfBaths =S.L_Keyword4,
										--	 T.TotalBaths =S.L_Keyword3,
											 T.TotalBeds =S.Total_Beds,
											 T.StreetNumber =S.L_AddressNumber,
											 T.StreetName =S.L_AddressStreet,
											-- T.StreetSuffix =S.StreetSuffix,
											 T.City =S.L_City,
											 --T.County =S.LM_char10_70,
											 T.State =S.L_State,
											 --T.SubDivision =S.LM_Char25_29,
											 T.ZipCode =S.L_Zip,
											 T.Price =S.L_AskingPrice,
											 T.Sqft =S.L_SquareFeet,
											 --T.Pricepersqft =S.,
											 T.Acre =S.ACRES,
											 T.PropertyType =S.L_Type_,
											 T.Status =S.L_Status,
											 T.OfficeName =S.officename,
											 T.photoUrl =S.Photolocation,
											 --T.WaterFront =case  When S.LFD_WaterFrontageType_66 like '%Waterfront Community%' then 1 else 0 end,
											 T.Shortsale =case  When S.L_Remarks like '%Short Sale%' then 1 Else 0 End,
											 T.Foreclosure =case When S.L_Remarks like '%Foreclosure%' then 1 Else 0 End, --or S.LM_char10_35=1 then 1 Else 0 End,
											 --T.IsOpenHouse = case S.IsOpenHouse When 1 then 1 Else 0 End,
											 --T.OpenHouseBegins =S.OpenHouseBegins,
											 --T.OpenHouseClose =S.OpenHouseClose,
											 --T.PriceChangedDate =S.,
											-- T.LastModifiedDate =S.MatrixModifiedDT,
											 T.YearBuilt =S.LM_Int4_1,
										    T.PublicRemark =S.L_Remarks;
											 
		select  ListId,MLSId,FullBaths, HalfBaths,TotalBaths,TotalBeds,Address,StreetNumber,StreetName,StreetSuffix,City,County, State,SubDivision,ZipCode,
		        Price,Sqft, Pricepersqft, Acre,PropertyType,Status,OfficeName,photoUrl,WaterFront,Shortsale,Foreclosure,IsOpenHouse,OpenHouseBegins,OpenHouseClose,
		        PriceChangedDate,LastModifiedDate,YearBuilt,PublicRemark,PropertySubType,Area,Neighbourhood,cast(CONVERT (DATE, DateViewedFavRat) as Varchar(max)) 'DateViewedFavRatWithoutTime',DateViewedFavRat,ImagePath_FromXML,ViewedTotalCount,RatingCount,OffMarket,ActivityType 
		from tbl_DataVwdFavRat
	IF OBJECT_ID('tbl_CreateXMLDoc') IS NOT NULL DROP TABLE tbl_CreateXMLDoc   
    IF OBJECT_ID('tbl_DataVwdFavRat') IS NOT NULL DROP TABLE tbl_DataVwdFavRat
				
END
GO
/****** Object:  StoredProcedure [dbo].[prc_Execute_YAR_Scheduler_UndecodedValues]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[prc_Execute_YAR_Scheduler_UndecodedValues]
AS
BEGIN

-------------------------------------------------------------------------------------------------------------------
----//Execute XML Fetch Procedure
-------------------------------------------------------------------------------------------------------------------
      --EXEC SDM_PRC_FetchXml;
      --EXEC SDM_PRC_FetchXml_LOOKUP;
-------------------------------------------------------------------------------------------------------------------
DECLARE @TableNameS AS Varchar(Max),
        @XmlPath AS Varchar(Max),
        @TxtFilePathS As Varchar(Max);
---//Both @TableName And @DataFilePath Parameter Mush have Same Number Of Delimeters
---//Table Names And File Paths Must Be Equal In Numbers

SET @TableNameS   = 'RE_1'
SET @TxtFilePathS = '\\192.168.20.254\exports\MLS\YAR_MLS\Feed\ResDecode'
-------------------------------------------------------------------------------------------------------------------
----//Create Data From XML MetaData
----//Fetch Record From Text File and Insert Into specifide table
-------------------------------------------------------------------------------------------------------------------
DECLARE @Tab_Name As Varchar(Max),
        @TextFile AS Varchar(Max);                 
                       
	DECLARE @CursorExecHVScheduler CURSOR
	    SET @CursorExecHVScheduler = CURSOR FAST_FORWARD
        FOR
		     SELECT Col1 AS 'Table Name' ,Col2 'Text File'
               FROM [dbo].[Fun_YAR_SplitExecuteScheduler] (@TableNames,@TxtFilePathS,'|')

       OPEN @CursorExecHVScheduler
		         FETCH NEXT FROM @CursorExecHVScheduler
		          INTO @Tab_Name,@TextFile
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
	
              --Execute Proceduer prc_HVScheduler--
              EXEC dbo.prc_YAR_Scheduler @Tab_Name,@TextFile
            
                		    
		     FETCH NEXT FROM @CursorExecHVScheduler
			  INTO @Tab_Name,@TextFile
			  
        END
             CLOSE @CursorExecHVScheduler                           --//Close Cursor
        DEALLOCATE @CursorExecHVScheduler
        
-------------------------------------------------------------------------------------------------------------------
----//Rename Existng Table Names
-------------------------------------------------------------------------------------------------------------------

DECLARE @Old_TableName AS Varchar(MAX),
        @SQL_String1 As Varchar (MAX),
        @SQL_String2 As Varchar (MAX);
            
	DECLARE @CursorRenameExistingTableName CURSOR
	    SET @CursorRenameExistingTableName = CURSOR FAST_FORWARD
        FOR
		     SELECT Items  
		       FROM [dbo].[Fun_YAR_SplitTableName](@TableNameS,'|')
                     
       OPEN @CursorRenameExistingTableName
		         FETCH NEXT FROM @CursorRenameExistingTableName
		          INTO @Old_TableName
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
           SET @Old_TableName = REPLACE(@Old_TableName,' ','')
           SET @SQL_String1 = '
                            
                              
                              IF OBJECT_ID(''Old_tbl_undecode_{Name}'') IS NOT NULL DROP TABLE Old_tbl_undecode_{Name};
                              IF EXISTS (SELECT name FROM sysobjects WHERE name = ''tbl_undecode_{Name}'')
                              EXEC sp_rename tbl_undecode_{Name} , Old_tbl_undecode_{Name}
                		      '
           
           SET @SQL_String2 = REPLACE(@SQL_String1,'{Name}',@Old_TableName);
           
           EXECUTE(@SQL_String2);
                		       
		     FETCH NEXT FROM @CursorRenameExistingTableName
			  INTO @Old_TableName
			  
        END
             CLOSE @CursorRenameExistingTableName                           --//Close Cursor
        DEALLOCATE @CursorRenameExistingTableName
        
-------------------------------------------------------------------------------------------------------------------
----//Rename Table Names
-------------------------------------------------------------------------------------------------------------------  
--RS_1     
         IF OBJECT_ID('tbl_undecode_RE_1') IS NOT NULL DROP TABLE tbl_undecode_RE_1;
        EXEC sp_rename 'New_tbl_RE_1', 'tbl_undecode_RE_1'
		

END;
GO
/****** Object:  StoredProcedure [dbo].[Prc_Append_Columns_YARView]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prc_Append_Columns_YARView]
                      
AS
BEGIN
--------------------------------------------------------------------------------------------------------------
-----//APPEND UNDECODED VALUES TO VIEW
-------------------------------------------------------------------------------------------------------------- 
 
  IF OBJECT_ID('tbl_UndecodeView') IS NOT NULL DROP TABLE tbl_UndecodeView;
        
        SELECT * INTO tbl_UndecodeView FROM
        (SELECT L_City,	L_ListingID FROM tbl_undecode_RE_1
        UNION ALL
        SELECT L_City, L_ListingID FROM YAR_VIEW 
         ) T       
		
		ALTER TABLE YAR_VIEW 
		ALTER COLUMN  L_ListingID INT	
		
		ALTER TABLE tbl_UndecodeView 
		ALTER COLUMN  L_ListingID INT			  
        
				
		UPDATE YAR_VIEW 
		SET YAR_VIEW.L_City_NEW = (SELECT STUFF((SELECT ',' + rtrim(CONVERT(Varchar(MAX),tbl_UndecodeView.L_City))
				FROM YAR_MLS.dbo.tbl_UndecodeView
				WHERE  YAR_MLS.dbo.tbl_UndecodeView.L_ListingID=YAR_VIEW.L_ListingID
				FOR XML PATH('')),1,1,''))
				
		
			EXEC sp_rename 'YAR_VIEW.L_City', 'L_City_OLD', 'COLUMN';				
			
			EXEC sp_rename 'YAR_VIEW.L_City_NEW', 'L_City', 'COLUMN';
			--EXEC sp_rename 'CW_VIEW.longitude', 'LMD_MP_Longitude', 'COLUMN';
			
			
			
				
						 

        


END;
GO
/****** Object:  StoredProcedure [dbo].[PRC_Create_Column]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PRC_Create_Column]
	
AS
BEGIN


---------//UPDATION FOR TOTAL BED
   UPDATE tbl_RE_1
   SET L_Keyword1 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L_Keyword1,'One','1'),'Two','2'),'Three','3'),'Four','4'),'Five Plus','5'),'Studio',''),'Seven','7'),'Six','6')
   where L_Keyword1 is not null
   
   UPDATE tbl_RN_6
   SET L_Keyword1 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L_Keyword1,'1 Bdrm','1'),'2 Brdms','2'),'3 Brdms','3'),'4 Bdrms','4'),'5+Bdrms','5'),'None',''),'Seven','7'),'Six','6')
   where L_Keyword1 is not null
   
    IF OBJECT_ID('tempBED') IS NOT NULL DROP TABLE tempBED;
    
    SELECT * INTO tempBED
	FROM 
	(SELECT tbl_RE_1.L_Keyword1 AS JobNumber,tbl_RE_1.L_ListingID
	FROM tbl_RE_1
	UNION all
	SELECT tbl_RN_6.L_Keyword1 AS JobNumber,tbl_RN_6.L_ListingID
	FROM tbl_RN_6) AS T
	
	--SELECT * FROM tempBED
	
    --ALTER TABLE YAR_VIEW 
    --ADD Total_Beds Int  
    
     
    UPDATE YAR_VIEW 
    SET YAR_VIEW.Total_Beds = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tempBED.JobNumber)
    FROM YAR_MLS.dbo.tempBED
    WHERE  YAR_MLS.dbo.tempBED.L_ListingID=YAR_VIEW.L_ListingID
    FOR XML PATH('')),1,0,''))
    
   drop table tempBED
    
    
    
   
--------//UPDATION FOR FULL BATH 
   UPDATE tbl_RE_1
   SET L_Keyword2 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L_Keyword2,'One','1'),'Two','2'),'Three','3'),'Four','4'),'Plus',''),'None',''),'N1',''),'Five or More','5')
   where L_Keyword2 is not null
   
   UPDATE tbl_RN_6
   SET L_Keyword2 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L_Keyword2,'One','1'),'Two','2'),'Three','3'),'Four','4'),'Plus',''),'None',''),'N1',''),'Five or More','5')
   where L_Keyword2 is not null
   
    IF OBJECT_ID('tempBath') IS NOT NULL DROP TABLE tempBath;
    
    SELECT * INTO tempBath
	FROM 
	(SELECT tbl_RE_1.L_keyword2 AS JobNumber,tbl_RE_1.L_ListingID
	FROM tbl_RE_1
	UNION all
	SELECT tbl_RN_6.L_keyword2 AS JobNumber,tbl_RN_6.L_ListingID
	FROM tbl_RN_6) AS T
	
	-- SELECT * FROM tempBath
	
	--ALTER TABLE YAR_VIEW 
 --   ADD Full_Bath Int
     
    UPDATE YAR_VIEW 
    SET YAR_VIEW.Full_Bath = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tempBath.JobNumber )
    FROM YAR_MLS.dbo.tempBath
    WHERE  YAR_MLS.dbo.tempBath.L_ListingID=YAR_VIEW.L_ListingID
    FOR XML PATH('')),1,0,''))
	
	drop table tempBath





--------//UPDATION FOR GARAGE
   UPDATE tbl_RE_1
   SET L_Keyword7 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L_Keyword7,'Garage 1','1'),'Garage 2','2'),'Garage 3','3'),'Garage 4','4'),'Garage 5','5'),'None',''),'BOTH','2')
   where L_Keyword7 is not null
  
   UPDATE tbl_RN_6
   SET L_Keyword6 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L_Keyword6,'Garage 1','1'),'Garage 2','2'),'Garage 3','3'),'Garage 4','4'),'Garage 5','5'),'None',''),'BOTH','2')
   where L_Keyword6 is not null
   
   IF OBJECT_ID('tempGARAGE') IS NOT NULL DROP TABLE tempGARAGE;
   
    SELECT * INTO tempGARAGE
	FROM 
	(SELECT tbl_RE_1.L_keyword7 AS JobNumber,tbl_RE_1.L_ListingID
	FROM tbl_RE_1
	UNION all
	SELECT tbl_RN_6.L_keyword6 AS JobNumber,tbl_RN_6.L_ListingID
	FROM tbl_RN_6) AS T	
	
	--SELECT * FROM tempGARAGE
	
	--ALTER TABLE YAR_VIEW 
 --   ADD Garage Int
     
    UPDATE YAR_VIEW 
    SET YAR_VIEW.Garage = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tempGARAGE.JobNumber )
    FROM YAR_MLS.dbo.tempGARAGE
    WHERE  YAR_MLS.dbo.tempGARAGE.L_ListingID=YAR_VIEW.L_ListingID
    FOR XML PATH('')),1,0,''))
	
	drop table tempGARAGE
	
	
	
--------//UPDATION FOR ACRES
	SELECT * INTO tempACRES
	FROM 
	(SELECT tbl_RE_1.L_Keyword9 AS JobNumber,tbl_RE_1.L_ListingID
	FROM tbl_RE_1
	UNION all
	SELECT tbl_LD_2.L_Keyword1 AS JobNumber,tbl_LD_2.L_ListingID
	FROM tbl_LD_2) AS T

	--SELECT * FROM tempACRES
	
	--ALTER TABLE YAR_VIEW 
 --   ADD ACRES VARCHAR(MAX)
     
    UPDATE YAR_VIEW 
    SET YAR_VIEW.ACRES = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tempACRES.JobNumber )
    FROM YAR_MLS.dbo.tempACRES
    WHERE  YAR_MLS.dbo.tempACRES.L_ListingID=YAR_VIEW.L_ListingID
    FOR XML PATH('')),1,0,''))
    
	drop table tempACRES
	
--------//UPDATION FOR AREA
	
	IF OBJECT_ID('tempAREA') IS NOT NULL DROP TABLE tempAREA;
   
    SELECT * INTO tempAREA
	FROM 
	(SELECT [YAR_VIEW].L_area AS JobNumber,[YAR_VIEW].L_ListingID
	 FROM [YAR_VIEW]
	) AS T	
	
	--SELECT * FROM tempAREA
	
	--ALTER TABLE YAR_VIEW 
 --   ADD Area VARCHAR(MAX)
     
    UPDATE YAR_VIEW 
    SET YAR_VIEW.Area = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tempAREA.JobNumber )
    FROM YAR_MLS.dbo.tempAREA
    WHERE  YAR_MLS.dbo.tempAREA.L_ListingID=YAR_VIEW.L_ListingID
    FOR XML PATH('')),1,0,''))
    
	UPDATE [YAR_MLS].[dbo].[YAR_VIEW]
	SET Area = RIGHT(Area, LEN(Area) - 5) where Area like '%-%' or Area  like '%[0-9]%'	
	
	--SELECT L_Area , Area,L_Listingid
	--FROM [YAR_MLS].[dbo].[YAR_VIEW]\
	update [YAR_MLS].[dbo].[YAR_VIEW]
	SET Area=REPLACE(AREA,' SOUTH EAST YUMA','SOUTH EAST YUMA') WHERE Area IS NOT NULL
	
	
	DROP TABLE tempAREA;
	
END
GO
/****** Object:  StoredProcedure [dbo].[SDM_PRC_FetchXml_LOOKUP]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SDM_PRC_FetchXml_LOOKUP]
                 
AS
BEGIN

DECLARE @XmlPath Varchar(Max);

    SET @XmlPath = '\\192.168.20.254\exports\MLS\YAR_MLS\XML\YAR_MLS_XML.16.2.26964'

------------------------------------------------------------------------------------------------------------------------------
------//Read Xml MetaData 
------//Fetch Records From Xml Meta Data And Insert Into Column-Match Table 
------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Tempdb.dbo.YAR_XMLwithOpenXML_LOOKUP') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_XMLwithOpenXML_LOOKUP
   CREATE TABLE Tempdb.dbo.YAR_XMLwithOpenXML_LOOKUP
                (
				  Id INT IDENTITY PRIMARY KEY,
				  XMLData XML,
                  LoadedDateTime DATETIME
                )
-----------------------------------------------------------------------------
-----//Fetch MataData From Xml And Insert Into Temprary Table
-----------------------------------------------------------------------------
DECLARE @StringXml_1 AS Varchar(Max),
        @StringXml_2 As Varchar(Max)
    
    SET @StringXml_1 = 'INSERT INTO Tempdb.dbo.YAR_XMLwithOpenXML_LOOKUP(XMLData, LoadedDateTime)
                             SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() 
                               FROM OPENROWSET(BULK ''{Path}.xml'', SINGLE_BLOB) AS x;'
        SET @StringXml_2 = REPLACE(@StringXml_1,'{Path}',@XmlPath)
       EXEC (@StringXml_2)


IF OBJECT_ID('Tempdb..YAR_LOOKUP') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_LOOKUP
   CREATE TABLE Tempdb.dbo.YAR_LOOKUP
                (
                LookupName varchar(MAX), 
                        VisibleName varchar(MAX), 
						LongValue varchar(MAX),
						ShortValue Varchar (MAX), 
						Value varchar(MAX)
                )
                
   DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)
         SELECT @XML = XMLData FROM Tempdb.dbo.YAR_XMLwithOpenXML_LOOKUP
                  
         EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML
         
         INSERT INTO Tempdb.dbo.YAR_LOOKUP (LookupName,VisibleName,LongValue,ShortValue,Value)
         SELECT distinct LookupName,VisibleName,LongValue,ShortValue,Value
					FROM OPENXML(@hDoc, '//METADATA-RESOURCE/Resource/METADATA-LOOKUP/LookupType/METADATA-LOOKUP_TYPE/Lookup')
					WITH 
					(
					    LookupName varchar(MAX) '../../LookupName',
						VisibleName varchar(MAX) '../../VisibleName',
						LongValue varchar(MAX) 'LongValue',
						ShortValue Varchar (MAX) 'ShortValue',
						Value varchar(MAX) 'Value'
						
						
					) as X
           
           EXEC sp_xml_removedocument @hDoc
        
   EXEC prc_InsertLOOKUP
  
END
GO
/****** Object:  StoredProcedure [dbo].[SDM_PRC_FetchXml]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SDM_PRC_FetchXml]
                 
AS
BEGIN

DECLARE @XmlPath Varchar(Max);

    SET @XmlPath = '\\192.168.20.254\exports\MLS\YAR_MLS\XML\YAR_MLS_XML.16.2.26964'

------------------------------------------------------------------------------------------------------------------------------
------//Read Xml MetaData 
------//Fetch Records From Xml Meta Data And Insert Into Column-Match Table 
------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Tempdb..YAR_XMLwithOpenXML') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_XMLwithOpenXML
   CREATE TABLE Tempdb.dbo.YAR_XMLwithOpenXML
                (
				  Id INT IDENTITY PRIMARY KEY,
				  XMLData XML,
                  LoadedDateTime DATETIME
                )
-----------------------------------------------------------------------------
-----//Fetch MataData From Xml And Insert Into Temprary Table
-----------------------------------------------------------------------------
DECLARE @StringXml_1 AS Varchar(Max),
        @StringXml_2 As Varchar(Max)
    
    SET @StringXml_1 = 'INSERT INTO Tempdb.dbo.YAR_XMLwithOpenXML(XMLData, LoadedDateTime)
                             SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() 
                               FROM OPENROWSET(BULK ''{Path}.xml'', SINGLE_BLOB) AS x;'
        SET @StringXml_2 = REPLACE(@StringXml_1,'{Path}',@XmlPath)
       EXEC (@StringXml_2)

     --SELECT Id,XMLData,LoadedDateTime FROM Tempdb.dbo.YAR_XMLwithOpenXML
-----------------------------------------------------------------------------
-----//Create Temprary Table "YAR_ColumnMatch" For Storing System Names 
-----------------------------------------------------------------------------
IF OBJECT_ID('Tempdb..YAR_ColumnMatch') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_ColumnMatch
   CREATE TABLE Tempdb.dbo.YAR_ColumnMatch
                (
                  PropertyType Varchar(Max),
				  SystemName Varchar(Max),
				  LongName Varchar(Max),
				  DataType Varchar(Max),
                  MaximumLength INT,
                  LookupName varchar(MAX)
                  
                )
                
   DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)
         SELECT @XML = XMLData FROM Tempdb.dbo.YAR_XMLwithOpenXML
                  
         EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML
         
         INSERT INTO Tempdb.dbo.YAR_ColumnMatch (PropertyType,SystemName,LongName,DataType,MaximumLength,LookupName)
         SELECT DISTINCT PropertyType,SystemName,LongName,DataType,MaximumLength,LookupName
         
					FROM OPENXML(@hDoc, '//METADATA-RESOURCE/Resource/METADATA-CLASS/Class/METADATA-TABLE/Field')
					WITH 
					(
						PropertyType varchar(MAX) '../../ClassName',
						SystemName varchar(MAX) 'SystemName',
						LongName Varchar (MAX) 'LongName',
						MaximumLength varchar(MAX) 'MaximumLength',
						DataType varchar(MAX) 'DataType',
						LookupName varchar(MAX) 'LookupName'
						
					) as X
           
           EXEC sp_xml_removedocument @hDoc
        
    EXEC dbo.prc_InsertColumnMatch;
  
END
GO
/****** Object:  StoredProcedure [dbo].[Prc_Create_YAR_View]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prc_Create_YAR_View]
                       (
                       @Tables Varchar(Max),
                       @DataFiles Varchar(Max)
                       ) 
AS
BEGIN
--------------------------------------------------------------------------------------------------------------
-----//Declare Cursor For Fetching Txt File Column Name And Store In "Tempdb.dbo.BulkColumnMatch" Table
-------------------------------------------------------------------------------------------------------------- 
    IF OBJECT_ID('Tempdb..YAR_BulkColumnMatch') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_BulkColumnMatch
    CREATE TABLE Tempdb.dbo.YAR_BulkColumnMatch  (ColumnName Varchar(MAX));
    
    IF OBJECT_ID('Tempdb..YAR_txtColumnMatch') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_txtColumnMatch
    CREATE TABLE Tempdb.dbo.YAR_txtColumnMatch  (ColumnName Varchar(MAX));
      
    DECLARE @BulkSQL1 AS Varchar(Max),
            @BulkSql2 As Varchar(Max),
            @DataFilePath As Varchar(MAX),
            @TabName As Varchar(Max);
    
    DECLARE @CursorColumnFetch CURSOR
	    SET @CursorColumnFetch = CURSOR FAST_FORWARD
        FOR
		         SELECT Col1,Col2  
		           FROM [dbo].[Fun_YAR_Split_TableName_Path Name](@DataFiles,@Tables,'|')
		           
       OPEN @CursorColumnFetch
		         FETCH NEXT FROM @CursorColumnFetch
		          INTO @DataFilePath,@TabName
		         WHILE @@FETCH_STATUS = 0
      BEGIN 	

    SET @BulkSQL1 = '  
                       IF OBJECT_ID(''Tempdb..YAR_Col_{Name}'') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_Col_{Name}
                                             
                       CREATE TABLE tempdb.dbo.YAR_Col_{Name} (ColumnName VARCHAR(MAX))
                       
                       DECLARE @BulkString1 AS VARCHAR(MAX),
                               @BulkString2 AS VARCHAR(MAX);
                        
                       BULK INSERT Tempdb.dbo.YAR_BulkColumnMatch
                       FROM ''{Path}.txt''
                       WITH (
                             FIRSTROW = 1,
                             LASTROW = 1,
                             ROWTERMINATOR = ''\n''
                            )
                       
                       SET @BulkString1 = (SELECT ColumnName FROM Tempdb.dbo.YAR_BulkColumnMatch)
                       SET @BulkString2 = REPLACE(@BulkString1,''	'',''|'')
                       
                       TRUNCATE TABLE Tempdb.dbo.YAR_BulkColumnMatch
                       
                       INSERT INTO tempdb.dbo.YAR_Col_{Name} (ColumnName)
                                                      SELECT  REPLACE(Items,'' '','''')
                                                        FROM [dbo].[Fun_YAR_SplitColumn]((@BulkString2),''|'') 
                       
                       INSERT INTO Tempdb.dbo.YAR_txtColumnMatch (ColumnName)
                                                          SELECT  REPLACE(Items,'' '','''')
                                                            FROM [dbo].[Fun_YAR_SplitColumn]((@BulkString2),''|'')                                                                      
                  '
                                    
    SET @BulkSql2 = REPLACE(@BulkSQL1,'{Path}',@DataFilePath)
    SET @BulkSql2 = REPLACE(@BulkSql2,'{Name}',@TabName)
    
    --SELECT @BulkSql2
    
    EXEC (@BulkSql2)
   
    
    
    FETCH NEXT FROM @CursorColumnFetch
			  INTO @DataFilePath,@TabName
	  
    END
        CLOSE @CursorColumnFetch                           --//Close Cursor
   DEALLOCATE @CursorColumnFetch 
   
   --SELECT Distinct ColumnName FROM Tempdb.dbo.BulkColumnMatch
--------------------------------------------------------------------------------------------------------------
-----//Delete Record From Tempdb.YAR_Col_2  '1780'
--------------------------------------------------------------------------------------------------------------   
    --DELETE FROM Tempdb.dbo.YAR_Col_2
    --      WHERE ColumnName = '1780'
--------------------------------------------------------------------------------------------------------------
-----//Declare Cursor For Create View 
--------------------------------------------------------------------------------------------------------------    
    DECLARE @Items As VARCHAR(MAX),
            @TableName AS Varchar(Max),
            @Name As Varchar(Max),
            @PropertyType AS Varchar(Max),
            @IVString1 AS Varchar(Max),
            @IVString2 AS Varchar(Max),
            @IVString3 AS Varchar(Max),
            @IVString4 AS Varchar(Max),
            @SystemName AS Varchar(Max),
            @ColumnName As Varchar(Max)
    
    DECLARE @CursorViewString CURSOR
	    SET @CursorViewString = CURSOR FAST_FORWARD
        FOR
		         SELECT Items  
		           FROM [dbo].[Fun_YAR_View_SplitPropertyType](@Tables,'|')
		           
       OPEN @CursorViewString
		         FETCH NEXT FROM @CursorViewString
		          INTO @Items
		         WHILE @@FETCH_STATUS = 0
      BEGIN 	        
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
   SET @TableName = REPLACE(@Items,' ','')
   SET @PropertyType = @Items
   
   SET @IVString1 = '
                    IF OBJECT_ID(''Tempdb..YAR_tbl_{Name}'') IS NOT NULL DROP TABLE Tempdb.dbo.YAR_tbl_{Name}
				    
                    CREATE TABLE tempdb.dbo.YAR_tbl_{Name} (ColumnName VARCHAR(MAX))

                    DECLARE @SystemName AS Varchar(Max),
                            @ColumnName As Varchar(Max)
                    
                    DECLARE @CursorCreateView CURSOR
						SET @CursorCreateView = CURSOR FAST_FORWARD
						FOR
								 SELECT DISTINCT SystemName  
								   FROM dbo.tbl_ColumnMatch
								  WHERE PropertyType IN (SELECT Items  
		                                                   FROM [dbo].[Fun_YAR_View_SplitPropertyType](''RE_1|LD_2|CI_3|MF_4|BU_5|RN_6|ActiveAgent'',''|''))
		                            AND SystemName IN (SELECT Distinct ColumnName FROM Tempdb.dbo.YAR_txtColumnMatch)
		                            					           
					   OPEN @CursorCreateView
								 FETCH NEXT FROM @CursorCreateView
								  INTO @SystemName
								 WHILE @@FETCH_STATUS = 0
					  BEGIN 
					         
					         IF EXISTS (SELECT ColumnName FROM tempdb.dbo.YAR_Col_{Name}
					                                     --WHERE PropertyType = ''{Condition}''
					                                       WHERE ColumnName = @SystemName)
					            BEGIN
					                SET @ColumnName = ''[''+@SystemName+'']''
					            END;
					         ELSE
					            BEGIN
					                 SET @ColumnName = ''NULL ''+''[''+@SystemName+'']''
					            END;
					          
						     INSERT INTO tempdb.dbo.YAR_tbl_{Name} (ColumnName)
						                                VALUES (@ColumnName)
						     
							 FETCH NEXT FROM @CursorCreateView
							  INTO @SystemName
							  
						END
					  CLOSE @CursorCreateView                           
			     DEALLOCATE @CursorCreateView 
			     '
    --SELECT @Items AS Items
    
	SET @IVString2 = REPLACE(@IVString1,'{Name}',@TableName)
	SET @IVString3 = REPLACE(@IVString2,'@Tables',@Tables)
	SET @IVString4 = REPLACE(@IVString3,'{Condition}',@Items)
	
	--SELECT @IVString4 AS 'test'
	
   EXEC (@IVString4)
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
		     
		     FETCH NEXT FROM @CursorViewString
			  INTO @Items
			  
        END
             CLOSE @CursorViewString                           
        DEALLOCATE @CursorViewString 
        
 -- 'RE_1|LD_2|CI_3|MF_4|BU_5|RN_6|ActiveAgent|ActiveOffice'
DECLARE @RE_1 AS Varchar(Max),
        @LD_2 As Varchar(Max),        
        @CI_3 As Varchar(Max),
        @MF_4 As Varchar(Max),
        @BU_5 As Varchar(Max),
        @RN_6 As Varchar(Max),        
        @ActiveAgent As Varchar(Max),
        @ActiveOffice As Varchar(Max),        
              
        @String As Varchar(Max),
        @FinalString AS Varchar(Max)
      
 -----------------------------------------------------------------------------
 SELECT @RE_1 = COALESCE(@RE_1 + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_RE_1
 -----------------------------------------------------------------------------
 SELECT @LD_2 = COALESCE(@LD_2 + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_LD_2
 -----------------------------------------------------------------------------
 SELECT @CI_3 = COALESCE(@CI_3 + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_CI_3
 -----------------------------------------------------------------------------
 SELECT @MF_4 = COALESCE(@MF_4 + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_MF_4
 -----------------------------------------------------------------------------
 SELECT @BU_5 = COALESCE(@BU_5 + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_BU_5
 -----------------------------------------------------------------------------
 SELECT @RN_6 = COALESCE(@RN_6 + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_RN_6
 -----------------------------------------------------------------------------
 SELECT @ActiveAgent = COALESCE(@ActiveAgent + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_ActiveAgent
 -----------------------------------------------------------------------------
 --SELECT @ActiveOffice = COALESCE(@ActiveOffice + ', ', '') + ColumnName from tempdb.dbo.YAR_tbl_ActiveOffice
 -----------------------------------------------------------------------------
 
 -- 'RE_1|LD_2|CI_3|MF_4|RT_5'
IF OBJECT_ID('All_Properties_YAR') IS NOT NULL DROP VIEW All_Properties_YAR;     
SET @String  =  ' CREATE VIEW All_Properties_YAR AS '
               +' SELECT  LL.latitude,LL.longitude, ' + REPLACE(@RE_1,'[L_ListingID]','RES.[L_ListingID]') +',''Residential'' as Class FROM tbl_RE_1 RES' 
               +' LEFT JOIN A_lat_lon_YAR LL ON RES.[L_ListingID] = LL.[L_ListingID] '              
              
               +' UNION ALL '
               +' SELECT  LL.latitude,LL.longitude, ' + REPLACE(@LD_2,'[L_ListingID]','LD.[L_ListingID]') +',''Land'' as Class FROM tbl_LD_2 LD' 
               +' LEFT JOIN A_lat_lon_YAR LL ON LD.[L_ListingID] = LL.[L_ListingID] '              
              
               +' UNION ALL '
               +' SELECT  LL.latitude,LL.longitude,  ' + REPLACE(@CI_3,'[L_ListingID]','CI.[L_ListingID]') +',''Comm'' as Class FROM tbl_CI_3 CI'
               +' LEFT JOIN A_lat_lon_YAR LL ON CI.[L_ListingID] = LL.[L_ListingID] '               
                          
                 
               +' UNION ALL '
               +' SELECT  LL.latitude,LL.longitude,  ' + REPLACE(@MF_4,'[L_ListingID]','MULTI.[L_ListingID]') +',''MF'' as Class FROM tbl_MF_4 MULTI'
               +' LEFT JOIN A_lat_lon_YAR LL ON MULTI.[L_ListingID] = LL.[L_ListingID] '               
               
               +' UNION ALL '
               +' SELECT  LL.latitude,LL.longitude, ' + REPLACE(@BU_5,'[L_ListingID]','BU.[L_ListingID]') +',''Business'' as Class FROM tbl_BU_5 BU'
               +' LEFT JOIN A_lat_lon_YAR LL ON BU.[L_ListingID] = LL.[L_ListingID] '
               
               +' UNION ALL '
               +' SELECT  LL.latitude,LL.longitude,  ' + REPLACE(@RN_6,'[L_ListingID]','RN.[L_ListingID]') +',''Rental'' as Class FROM tbl_RN_6 RN'
               +' LEFT JOIN A_lat_lon_YAR LL ON RN.[L_ListingID] = LL.[L_ListingID] '
               
               +' UNION ALL '
               +' SELECT  LL.latitude,LL.longitude, ' + REPLACE(@ActiveAgent,'[U_AgentID]','AGENT.[U_AgentID]') +',''Agent'' as Class FROM tbl_ActiveAgent AGENT'
               +' LEFT JOIN A_lat_lon_YAR LL ON AGENT.[U_AgentID] = LL.[L_ListingID] '
               
               --+' UNION ALL '
               --+' SELECT   ' + @ActiveOffice +',''Office'' as Class FROM tbl_ActiveOffice '
               
----     --SET @String = REPLACE(@String,'[ClassKey]','CONVERT(varchar(MAX),[ClassKey]) AS [ClassKey]')
----     --SET @String = REPLACE(@String,'NULL CONVERT(varchar(MAX),[ClassKey]) AS ClassKey','NULL [ClassKey]')  

       
     EXEC (@String)     
     SELECT @String AS 'View Script' 

---------------------------------------------------------------------------------------------------------------------
------//Create Table All_Properties From View
---------------------------------------------------------------------------------------------------------------------
    IF OBJECT_ID('NEW_YAR_VIEW') IS NOT NULL DROP TABLE NEW_YAR_VIEW; --YAR_VIEW
    SELECT distinct * INTO NEW_YAR_VIEW
             FROM All_Properties_YAR

-------------------------------------------------------------------------------------------------------------------
----//Rename Table from All_Properties to Old_All_Properties
-------------------------------------------------------------------------------------------------------------------

		IF OBJECT_ID('Old_YAR_VIEW') IS NOT NULL DROP TABLE Old_YAR_VIEW;
        IF EXISTS (SELECT name FROM sysobjects WHERE name = 'YAR_VIEW')
        EXEC sp_rename  YAR_VIEW , Old_YAR_VIEW
        
        
-------------------------------------------------------------------------------------------------------------------
----//Rename Table from New_All_Properties_MRIS to All_Properties_MRIS
-------------------------------------------------------------------------------------------------------------------
      
        IF EXISTS (SELECT name FROM sysobjects WHERE name = 'New_YAR_VIEW')
        EXEC sp_rename New_YAR_VIEW , YAR_VIEW  
        
  UPDATE YAR_VIEW
  SET L_AddressStreet=Replace(L_AddressStreet,'.',' ')
  WHERE L_AddressStreet is not null
----------------------------------------------------------------------------------------------------------------------
--Modifiyting an Office name to YAR_VIEW
----------------------------------------------------------------------------------------------------------------------    
   ALTER TABLE YAR_VIEW 
   ADD OfficeID VARCHAR(MAX)
     
   UPDATE YAR_VIEW 
   SET YAR_VIEW.OfficeID = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tbl_ActiveOffice.[O_ShortName])
    FROM YAR_MLS.dbo.tbl_ActiveOffice
    WHERE  YAR_MLS.dbo.tbl_ActiveOffice.O_OfficeID=YAR_VIEW.L_ListOffice1
    FOR XML PATH('')),1,0,''))
   
     ALTER TABLE YAR_VIEW 
   ADD OfficeName VARCHAR(MAX)
     
   UPDATE YAR_VIEW 
   SET YAR_VIEW.OfficeName = (SELECT STUFF((SELECT convert(VARCHAR(MAX),tbl_ActiveOffice.[O_OrganizationName])
    FROM YAR_MLS.dbo.tbl_ActiveOffice
    WHERE  YAR_MLS.dbo.tbl_ActiveOffice.O_OfficeID=YAR_VIEW.L_ListOffice1
    FOR XML PATH('')),1,0,''))
    
    ALTER TABLE YAR_VIEW 
    ADD Total_Beds Int 
    
    ALTER TABLE YAR_VIEW 
    ADD Full_Bath Int
    
    ALTER TABLE YAR_VIEW 
    ADD Garage Int
    
    ALTER TABLE YAR_VIEW 
    ADD ACRES VARCHAR(MAX)
    
    ALTER TABLE YAR_VIEW 
    ADD Area VARCHAR(MAX)
    
    EXEC PRC_Create_Column;
  -----------------------------------------------------------------------------------------------------------------------
  --City Decoded value code 
  -----------------------------------------------------------------------------------------------------------------------  
     Alter table YAR_VIEW
     ADD L_City_NEW VARCHAR(MAX)
     
     EXEC [Prc_Append_Columns_YARView]
     
     UPDATE YAR_VIEW 
     SET L_CITY = REPLACE(L_CITY,'_','')
     WHERE L_CITY LIKE '%_%'
-------------------------------------------------------------------------------------------------------------------------
----//FREE SQL SERVER MEMORY USED BY PROCEDURES
-----------------------------------------------------------------------------------------------------------------------

SET NOCOUNT ON

EXEC sp_configure 'show advanced options', 1
RECONFIGURE --WITH OVERRIDE
CHECKPOINT

EXEC sp_configure 'max server memory', 2048
RECONFIGURE --WITH OVERRIDE
CHECKPOINT

WAITFOR DELAY '00:00:30'
EXEC sp_configure 'max server memory', 2147483647
RECONFIGURE --WITH OVERRIDE
CHECKPOINT

EXEC sp_configure 'show advanced options', 0
RECONFIGURE --WITH OVERRIDE
CHECKPOINT


END;
GO
/****** Object:  StoredProcedure [dbo].[prc_Execute_YAR_Scheduler]    Script Date: 04/18/2016 06:21:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[prc_Execute_YAR_Scheduler]
AS
BEGIN

-------------------------------------------------------------------------------------------------------------------
----//Execute XML Fetch Procedure
-------------------------------------------------------------------------------------------------------------------
      EXEC SDM_PRC_FetchXml;
      EXEC SDM_PRC_FetchXml_LOOKUP;
-------------------------------------------------------------------------------------------------------------------
DECLARE @TableNameS AS Varchar(Max),
        @XmlPath AS Varchar(Max),
        @TxtFilePathS As Varchar(Max);
---//Both @TableName And @DataFilePath Parameter Mush have Same Number Of Delimeters
---//Table Names And File Paths Must Be Equal In Numbers

SET @TableNameS   = 'RE_1|LD_2|CI_3|MF_4|BU_5|RN_6|ActiveAgent|Office'
SET @TxtFilePathS = '\\192.168.20.254\exports\MLS\YAR_MLS\Feed\Residential|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\Land|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\Commercial-Investment|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\MF|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\Business|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\Rental|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\ActiveAgent|\\192.168.20.254\exports\MLS\YAR_MLS\Feed\Office'
-------------------------------------------------------------------------------------------------------------------
----//Create Data From XML MetaData
----//Fetch Record From Text File and Insert Into specifide table
-------------------------------------------------------------------------------------------------------------------
DECLARE @Tab_Name As Varchar(Max),
        @TextFile AS Varchar(Max);                 
                       
	DECLARE @CursorExecHVScheduler CURSOR
	    SET @CursorExecHVScheduler = CURSOR FAST_FORWARD
        FOR
		     SELECT Col1 AS 'Table Name' ,Col2 'Text File'
               FROM [dbo].[Fun_YAR_SplitExecuteScheduler] (@TableNames,@TxtFilePathS,'|')

       OPEN @CursorExecHVScheduler
		         FETCH NEXT FROM @CursorExecHVScheduler
		          INTO @Tab_Name,@TextFile
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
	
              --Execute Proceduer prc_HVScheduler--
              EXEC dbo.prc_YAR_Scheduler @Tab_Name,@TextFile
            
                		    
		     FETCH NEXT FROM @CursorExecHVScheduler
			  INTO @Tab_Name,@TextFile
			  
        END
             CLOSE @CursorExecHVScheduler                           --//Close Cursor
        DEALLOCATE @CursorExecHVScheduler
        
-------------------------------------------------------------------------------------------------------------------
----//Rename Existng Table Names
-------------------------------------------------------------------------------------------------------------------

DECLARE @Old_TableName AS Varchar(MAX),
        @SQL_String1 As Varchar (MAX),
        @SQL_String2 As Varchar (MAX);
            
	DECLARE @CursorRenameExistingTableName CURSOR
	    SET @CursorRenameExistingTableName = CURSOR FAST_FORWARD
        FOR
		     SELECT Items  
		       FROM [dbo].[Fun_YAR_SplitTableName](@TableNameS,'|')
                     
       OPEN @CursorRenameExistingTableName
		         FETCH NEXT FROM @CursorRenameExistingTableName
		          INTO @Old_TableName
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
           SET @Old_TableName = REPLACE(@Old_TableName,' ','')
           SET @SQL_String1 = '
                            
                              
                              IF OBJECT_ID(''Old_tbl_{Name}'') IS NOT NULL DROP TABLE Old_tbl_{Name};
                              IF EXISTS (SELECT name FROM sysobjects WHERE name = ''tbl_{Name}'')
                              EXEC sp_rename tbl_{Name} , Old_tbl_{Name}
                		      '
           
           SET @SQL_String2 = REPLACE(@SQL_String1,'{Name}',@Old_TableName);
           EXECUTE(@SQL_String2);
                		       
		     FETCH NEXT FROM @CursorRenameExistingTableName
			  INTO @Old_TableName
			  
        END
             CLOSE @CursorRenameExistingTableName                           --//Close Cursor
        DEALLOCATE @CursorRenameExistingTableName
-------------------------------------------------------------------------------------------------------------------
----//Rename New Table Names
-------------------------------------------------------------------------------------------------------------------

DECLARE @New_TableName AS Varchar(MAX);
            
	DECLARE @CursorRenameNewTableName CURSOR
	    SET @CursorRenameNewTableName = CURSOR FAST_FORWARD
        FOR
		     SELECT Items  
		       FROM [dbo].[Fun_YAR_SplitTableName](@TableNameS,'|')
                     
       OPEN @CursorRenameNewTableName
		         FETCH NEXT FROM @CursorRenameNewTableName
		          INTO @New_TableName
		         WHILE @@FETCH_STATUS = 0
      BEGIN 
           SET @New_TableName = REPLACE(@New_TableName,' ','')
           SET @SQL_String1 = '
                               
                              --EXEC( ''ALTER TABLE New_tbl_{Name}
                              --        ALTER COLUMN sysid INT NOT NULL'')

                              --EXEC(''ALTER TABLE New_tbl_{Name}
                              --       ADD CONSTRAINT pk_SysId_{Name} PRIMARY KEY (sysid)'') 
                                                                                        
                              IF EXISTS (SELECT name FROM sysobjects WHERE name = ''New_tbl_{Name}'')
                              EXEC sp_rename New_tbl_{Name} , tbl_{Name}
                		      '
           
           SET @SQL_String2 = REPLACE(@SQL_String1,'{Name}',@New_TableName);
           --SELECT @SQL_String2 as pkey
           
           EXECUTE(@SQL_String2);
                		       
		     FETCH NEXT FROM @CursorRenameNewTableName
			  INTO @New_TableName
			  
        END
             CLOSE @CursorRenameNewTableName                           --//Close Cursor
        DEALLOCATE @CursorRenameNewTableName


 EXEC [dbo].[prc_Execute_YAR_Scheduler_UndecodedValues]
 
-----------------------------------------------------------------------------------------------------------------
--//Create View
-----------------------------------------------------------------------------------------------------------------

 EXEC [dbo].[Prc_Create_YAR_View] @TableNameS,@TxtFilePathS
       
-----------------------------------------------------------------------------------------------------------------
--//Removes comma (,) from price field records
-------------------------------------------------------------------------------------------------------------------

END;
GO
/****** Object:  Default [DF_tbl_LOOKUP_IsShow]    Script Date: 04/18/2016 06:21:33 ******/
ALTER TABLE [dbo].[tbl_LOOKUP] ADD  CONSTRAINT [DF_tbl_LOOKUP_IsShow]  DEFAULT ((0)) FOR [IsShow]
GO
