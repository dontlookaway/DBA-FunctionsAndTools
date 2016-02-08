SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [Process].[Udf_WorkingDays]
    (
      @StartDate Date
    , @EndDate Date
    , @Country Varchar(150)
    )
Returns Int
As
    Begin
        Declare @DaysToExclude Int, @CurrentDate Date=@StartDate;
		Declare @DaysCount Table (CalendarDate Date);


		While @CurrentDate<=@EndDate
		Begin
			If DateName(Weekday,@CurrentDate) Not In ('Saturday','Sunday') And Not Exists (Select 1 From [Lookups].[HolidayDays] As [HD] Where [HD].[HolidayDate]=@CurrentDate And [HD].[Country]=@Country)
			Begin
				Insert @DaysCount ( [CalendarDate] )
				Values  ( @CurrentDate )		    
			end
			Set @CurrentDate=DateAdd(Day,1,@CurrentDate)
		END


        Select  @DaysToExclude = Count(1)
        From    @DaysCount As [DC]

        Return @DaysToExclude;
    End;
GO
