defmodule Request do
  def get_data(table_row) do
    title_div = Floki.find(table_row, ".bookTitle")
    book_name = Floki.text(title_div)
    incomplete_book_url = hd Floki.attribute(title_div, "href")
    full_url = "https://www.goodreads.com" <> incomplete_book_url
    author = Floki.text(Floki.find(table_row, "[itemprop=author]"))
    unformatted_rating = Floki.text(Floki.find(table_row, ".minirating"))
    rating = unformatted_rating |> String.split("avg") |> hd |> String.trim
    amount_ratings = unformatted_rating |> String.split("—") |> tl |> hd |> String.trim |> String.split(" ") |> hd

    %{
      book_name: book_name,
      author: author,
      rating: rating,
      amount_ratings: amount_ratings,
      url: full_url,
    }
  end

  def info_scraper() do
    url = "https://www.goodreads.com/list/show/143500.Best_Books_of_the_Decade_2020_s"
    {:ok, %{status_code: 200, body: body}} = HTTPoison.get(url)

    # Get document
    {:ok, document} = Floki.parse_document(body)

    # Get the rows
    table_rows = Floki.find(document, "tr")

    # Map over the rows and get the data
    data = table_rows |> Enum.map(&get_data/1)

    # data
    
    # Transform to list of list
    data_list = data |> Enum.map(fn x -> [x.book_name, x.author, x.rating, x.amount_ratings, x.url] end)

    # Add headers to beginning of list
    data_list = [["Book Name", "Author", "Rating", "Amount of Ratings", "URL"]] ++ data_list

    # Write to csv
    file = File.open!("books.csv", [:write, :utf8])
    data_list |> CSV.encode |> Enum.each(&IO.write(file, &1))
  end


  # def scrape1 do
  #   url = "https://www.goodreads.com/list/show/143500.Best_Books_of_the_Decade_2020_s"
  #   {:ok, %{status_code: 200, body: body}} = HTTPoison.get(url)

  #   # Get document
  #   {:ok, document} = Floki.parse_document(body)

  #   # Find class bookTitle
  #   book_titles = Floki.find(document, ".bookTitle span")

  #   titles = book_titles |>
  #     Enum.map(fn title ->
  #       Floki.text(title)
  #     end)  
  # end




  # def scrape2 do
  #   url = "https://www.goodreads.com/list/show/143500.Best_Books_of_the_Decade_2020_s"
  #   {:ok, %{status_code: 200, body: body}} = HTTPoison.get(url)

  #   # Get document
  #   {:ok, document} = Floki.parse_document(body)

  #   # Find class bookTitle
  #   authors = Floki.find(document, "author")

  #   authors = authors |>
  #     Enum.map(fn author ->
  #       Floki.text(author)
  #     end)
  #     |> get_data
  # end
end


