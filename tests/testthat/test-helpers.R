context("testing helpers")

test_that("checking correct number EMS_IDs and REQ_IDs of lt_lake_sites and lt_lake_req()",
          {
            expect_length(lt_lake_sites(), 74)
            expect_length(lt_lake_req(), 654)
          }
          )

test_that("checking data type of lt_lake_sites() and lt_lake_req()",
         {
           expect_type(lt_lake_sites(), "character")
           expect_type(lt_lake_req(), "character")
         })