# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

language_list = [
    [ "ara", "Arabic" ],
    [ "chi_sim", "Chinese - Simplified" ],
    [ "chi_tra", "Chinese - Traditional" ],
    [ "deu", "German" ],
    [ "eng", "English" ],
    [ "fra", "French" ],
    [ "hin", "Hindi" ],
    [ "ind", "Indonesian" ],
    [ "ita", "Italian" ],
    [ "jpn", "Japanese" ],
    [ "kor", "Korean" ],
    [ "por", "Portuguese" ],
    [ "rus", "Russian" ],
    [ "spa", "Spanish" ],
    [ "tur", "Turkish" ],
]

language_list.each do |code, language|
  OcrLanguage.create( code: code, language: language )
end