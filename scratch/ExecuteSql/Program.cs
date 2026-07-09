using System;
using Microsoft.Data.SqlClient;
using System.IO;

namespace ExecuteSql
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "Server=tcp:macchiato.database.windows.net,1433;Initial Catalog=golffindb;User ID=superdb;Password=golffinP@$$;Pooling=False;Connect Timeout=30;Encrypt=True;Trust Server Certificate=False;Authentication=SqlPassword;Application Name=vscode-mssql;Connect Retry Count=1;Connect Retry Interval=10;Command Timeout=30";
            
            string sql = @"
CREATE OR ALTER PROCEDURE sp_GetOffersForRequest
    @RequestId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.Id,
        o.RequestId,
        o.SellerId,
        u.DisplayName AS SellerName,
        u.ProfileImageUrl AS SellerProfileImage,
        o.OfferPrice,
        o.Condition,
        o.Message,
        o.Status,
        o.CreatedAt
    FROM ISO_Offers o
    INNER JOIN Users u ON o.SellerId = u.Id
    WHERE o.RequestId = @RequestId
    ORDER BY o.CreatedAt ASC;
END
";

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.ExecuteNonQuery();
                        Console.WriteLine("Stored procedure executed successfully.");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error executing SQL: " + ex.Message);
            }
        }
    }
}
