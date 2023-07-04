require 'json'
require 'faraday'
require 'table_print'

def get_token
  credentials = JSON.parse(File.read('./credentials.json'))

  body = {
    grant_type: 'client_credentials',
    client_id: credentials['client_id'],
    client_secret: credentials['client_secret']
  }

  response = Faraday.post('https://accounts.spotify.com/api/token', body)

  JSON.parse(response.body)['access_token']
end

def get_artist_data(token)
  artists_ids = [
    '4gzpq5DPGxSnKTe4SA8HAU',
    '06HL4z0CvFAxyc27GXpf02',
    '53XhwfbYqKCa1cC15pYq2q',
    '4q3ewBCX7sLwd24euuV69X',
    '2ye2Wgw4gimLv2eAKyk1NB',
    '0C0XlULifJtAgn6ZNCW2eu',
    '6vWDO969PvNqNYHIOW5v0m',
    '6eUKZXaKkcviH0Ku9w2n3V',
    '0EmeFodog0BfCgMzAIvKQp',
    '1vCWHaC5f2uS3yhpwWbIA6'
  ]

  conn = Faraday.new(url: "https://api.spotify.com/v1/artists") do |req|
    req.headers['Authorization'] = "Bearer #{token}"
  end

  artists = artists_ids.map do |artist_id|
    artist_data = JSON.parse(conn.get(artist_id).body)
    track_data = JSON.parse(conn.get("#{artist_id}/top-tracks?market=CL").body)

    sorted_tracks = track_data['tracks'].sort_by { |track| [-track['popularity'], track['name']] }
    most_popular_track = sorted_tracks[1]

    {
      'name' => artist_data['name'],
      'popularity' => artist_data['popularity'],
      'most_popular_track' => most_popular_track['name'],
      'preview_url' => most_popular_track['preview_url']
    }
  end

  artists.sort_by! { |artist| artist['name'] }
end

token = get_token
artists = get_artist_data token
tp artists, :name, :popularity, {:most_popular_track => {:width => 100}}, :preview_url => {:width => 200}
