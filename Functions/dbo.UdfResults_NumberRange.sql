SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[UdfResults_NumberRange]
    (
      @StartNumber Int
    , @EndNumber Int
    )
/*
This function returns an integer table containing all integers in the range of@START_NUMBER through @END_NUMBER, inclusive. The maximum number of rows that this function can return is 16777216.
Original Query - http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=47685&SearchTerms=F_TABLE_NUMBER_RANGE
*/
Returns Table
As

Return
    ( Select [Number] = ( [a].[Number] + [b].[Number] )
                + -- Add the starting number for the final result set - The case is needed, because the start and end - numbers can be passed in any order
	Case When @StartNumber <= @EndNumber Then @StartNumber
         Else @EndNumber
    End
      From      ( Select Top 100 Percent
                            [Number] = Convert(Int , [N1].[N01] + [N2].[N02]
                            + [N3].[N03])
                  From      -- Cross rows from 3 tables based on powers of 16 - Maximum number of rows from cross join is 4096, 0 to 4095
                            ( Select    [N01] = 0
                              Union All Select    1 Union All Select    2
                              Union All Select    3 Union All Select    4
                              Union All Select    5 Union All Select    6
                              Union All Select    7 Union All Select    8
                              Union All Select    9 Union All Select    10
                              Union All Select    11 Union All Select    12
                              Union All Select    13 Union All Select    14
                              Union All Select    15 ) [N1]
                            Cross Join ( Select [N02] = 0 
										 Union All Select 16 Union All Select 32 
										 Union All Select 48 Union All Select 64
                                         Union All Select 80 Union All Select 96
                                         Union All Select 112 Union All Select 128
                                         Union All Select 144 Union All Select 160
                                         Union All Select 176 Union All Select 192
                                         Union All Select 208 Union All Select 224
                                         Union All Select 240 ) [N2]
                            Cross Join ( Select [N03] = 0
                                         Union All Select 256 Union All Select 512
                                         Union All Select 768 Union All Select 1024
                                         Union All Select 1280 Union All Select 1536
                                         Union All Select 1792 Union All Select 2048
                                         Union All Select 2304 Union All Select 2560
                                         Union All Select 2816 Union All Select 3072
                                         Union All Select 3328 Union All Select 3584
                                         Union All Select 3840 ) [N3]
                  Where     -- Minimize the number of rows crossed by selecting only rows - with a value less the the square root of rows needed.
                            [N1].[N01] + [N2].[N02] + [N3].[N03] < -- Square root of total rows rounded up to next whole number
		Convert(Int , Ceiling(Sqrt(Abs(@StartNumber - @EndNumber) + 1)))
                  Order By  1
                ) [a]
                Cross Join ( Select Top 100 Percent
                                    [Number] = Convert(Int , ( [N1].[N01]
                                                              + [N2].[N02]
                                                              + [N3].[N03] )
                                    * -- Square root of total rows rounded up to next whole number
		Convert(Int , Ceiling(Sqrt(Abs(@StartNumber - @EndNumber) + 1))))
                             From   -- Cross rows from 3 tables based on powers of 16 - Maximum number of rows from cross join is 4096, 0 to 4095
                                    ( Select    [N01] = 0
                                      Union All Select    1 Union All Select    2
                                      Union All Select    3 Union All Select    4
                                      Union All Select    5 Union All Select    6
                                      Union All Select    7 Union All Select    8
                                      Union All Select    9 Union All Select    10
                                      Union All Select    11 Union All Select    12
                                      Union All Select    13 Union All Select    14
                                      Union All Select    15 ) [N1]
                                    Cross Join ( Select [N02] = 0
                                                 Union All Select 16 Union All Select 32
                                                 Union All Select 48 Union All Select 64
                                                 Union All Select 80 Union All Select 96
                                                 Union All Select 112 Union All Select 128
                                                 Union All Select 144 Union All Select 160
                                                 Union All Select 176 Union All Select 192
                                                 Union All Select 208 Union All Select 224
                                                 Union All Select 240 ) [N2]
                                    Cross Join ( Select [N03] = 0
                                                 Union All Select 256 Union All Select 512 
												 Union All Select 768 Union All Select 1024
												 Union All Select 1280 Union All Select 1536
                                                 Union All Select 1792 Union All Select 2048
                                                 Union All Select 2304 Union All Select 2560
                                                 Union All Select 2816 Union All Select 3072
                                                 Union All Select 3328 Union All Select 3584
                                                 Union All Select 3840 ) [N3]
                             Where  -- Minimize the number of rows crossed by selecting only rows - with a value less the the square root of rows needed.
                                    [N1].[N01] + [N2].[N02] + [N3].[N03] < -- Square root of total rows rounded up to next whole number
		Convert(Int , Ceiling(Sqrt(Abs(@StartNumber - @EndNumber) + 1)))
                             Order By 1
                           ) [b]
      Where     [a].[Number] + [b].[Number] < -- Total number of rows
	Abs(@StartNumber - @EndNumber) + 1
                And
	-- Check that the number of rows to be returned - is less than or equal to the maximum of 16777216
                Case When Abs(@StartNumber - @EndNumber) + 1 <= 16777216
                     Then 1
                     Else 0
                End = 1
    );

GO
GRANT SELECT ON  [dbo].[UdfResults_NumberRange] TO [public]
GO
