module Neighborhoods

  CHICAGO_NEIGHBORHOODS = {
    'Cathedral District'   => [60611],
    'Central Station'      => [60605],
    'Dearborn Park'        => [60605],
    'Gold Coast'           => [60610, 60611],
    'Loop'                 => [60601, 60602, 60603, 60604, 60605, 60606, 60607, 60616],
    'Magnificent Mile'     => [60611],
    'Museum Campus'        => [60605],
    'Near North Side'      => [60610, 60611, 60642, 60654],
    'Near West Side'       => [60606, 60607, 60608, 60610, 60612, 60661],
    'New East Side'        => [60601],
    'Noble Square'         => [60622],
    'Old Town'             => [60610],
    'Printers Row'         => [60605],
    'Randolph Market'      => [60607, 60661],
    'River East'           => [60611],
    'River North'          => [60611, 60654],
    'River West'           => [60622, 60610],
    'South Loop'           => [60605, 60607, 60608, 60616],
    'Streeterville'        => [60611],
    'Tri-Taylor'           => [60612],
    'Ukrainian Village'    => [60622, 60612],
    'West Loop'            => [60607],
    'West Town'            => [60612, 60622, 60642, 60647],
    'Wicker Park'          => [60622],
    'Alta Vista Terrace'   => [60613],
    'Belmont Harbor'       => [60657],
    'Boys Town'            => [60613, 60657],
    'Bucktown'             => [60647, 60622, 60614],
    'DePaul'               => [60614],
    'Lakeview'             => [60657, 60613],
    'Lakeview Central'     => [60657],
    'Lakeview East'        => [60657, 60613],
    'Lincoln Park'         => [60614, 60610],
    'Lincoln Square'       => [60625],
    'North Center'         => [60618, 60613],
    'North Halsted'        => [60613, 60657],
    'Old Town Triangle'    => [60614],
    'Park West'            => [60614],
    'Ranch Triangle'       => [60614],
    'Roscoe Village'       => [60618, 60657],
    'Sheffield'            => [60614],
    'Uptown'               => [60640],
    'West DePaul'          => [60614],
    'Wrightwood Neighbors' => [60614],
    'Wrigleyville'         => [60613],
    'Andersonville'        => [60640],
    'Budlong Woods'        => [60625],
    'Buena Park'           => [60613, 60640],
    'East Ravenswood'      => [60613, 60640],
    'Edgewater'            => [60640, 60660],
    'Edgewater Glen'       => [60660, 60640],
    'Edison Park'          => [60631],
    'Middle Edgebrook'     => [60630, 60646],
    'North Edgebrook'      => [60630, 60646],
    'Old Irving Park'      => [60641],
    'Peterson Park'        => [60659],
    'Ravenswood'           => [60640, 60625, 60613],
    'West Ridge'           => [60645, 60659],
    'West Rogers Park'     => [60645, 60659, 60660],
    'Albany Park'          => [60625],
    'Avondale'             => [60618],
    'Belmont Gardens'      => [60641, 60639],
    'Forest Glen'          => [60630],
    'Irving Park'          => [60618],
    'Jefferson Park'       => [60630],
    'Mayfair'              => [60630],
    'North Park'           => [60625],
    'Norwood Park'         => [60631],
    'Old Edgebrook'        => [60646],
    'Old Norwood Park'     => [60631],
    'Portage Park'         => [60634, 60641],
    'Ravenswood Manor'     => [60625],
    'Sauganash'            => [60646, 60630],
    'Sauganash Woods'      => [60630],
    'Schorsch Forest View' => [60656],
    'South Edgebrook'      => [60646],
    'Union Ridge'          => [60656]
  }.freeze

  NYC_NEIGHBORHOODS = {
    'Central Bronx'                 => [10453, 10457, 10460],
    'Bronx Park and Fordham'        => [10458, 10467, 10468],
    'High Bridge and Morrisania'    => [10451, 10452, 10456],
    'Hunts Point and Mott Haven'    => [10454, 10455, 10459, 10474],
    'Kingsbridge and Riverdale'     => [10463, 10471],
    'Northeast Bronx'               => [10466, 10469, 10470, 10475],
    'Southeast Bronx'               => [10461, 10462, 10464, 10465, 10472, 10473],
    'Central Brooklyn'              => [11213, 11216, 11238],
    'Southwest Brooklyn'            => [11209, 11214, 11228],
    'Borough Park'                  => [11204, 11218, 11219, 11230],
    'Canarsie'                      => [11234, 11236],
    'Southern Brooklyn'             => [11223, 11224, 11229, 11235],
    'Northwest Brooklyn'            => [11201, 11205, 11215, 11217, 11231],
    'Flatbush'                      => [11203, 11210, 11225, 11226],
    'Brownsville'                   => [11233, 11212],
    'East New York and New Lots'    => [11207, 11208, 11239],
    'Greenpoint'                    => [11222],
    'Sunset Park'                   => [11220, 11232],
    'Williamsburg'                  => [11211],
    'Bushwick'                      => [11206, 11221, 11237],
    'Central Harlem'                => [10026, 10027, 10030, 10037, 10039],
    'Chelsea and Clinton'           => [10001, 10011, 10018, 10019, 10020, 10036],
    'East Harlem'                   => [10029, 10035],
    'Gramercy Park and Murray Hill' => [10010, 10016, 10017, 10022],
    'Greenwich Village and Soho'    => [10012, 10013, 10014],
    'Lower Manhattan'               => [10004, 10005, 10006, 10007, 10038, 10280],
    'Lower East Side'               => [10002, 10003, 10009],
    'Upper East Side'               => [10021, 10028, 10044, 10065, 10075, 10128],
    'Upper West Side'               => [10023, 10024, 10025],
    'Inwood and Washington Heights' => [10031, 10032, 10033, 10034, 10040],
    'Northeast Queens'              => [11361, 11362, 11363, 11364],
    'North Queens'                  => [11354, 11355, 11356, 11357, 11358, 11359, 11360],
    'Central Queens'                => [11365, 11366, 11367],
    'Jamaica'                       => [11412, 11423, 11432, 11433, 11434, 11435, 11436],
    'Northwest Queens'              => [11101, 11102, 11103, 11104, 11105, 11106],
    'West Central Queens'           => [11374, 11375, 11379, 11385],
    'Rockaways'                     => [11691, 11692, 11693, 11694, 11695, 11697],
    'Southeast Queens'              => [11004, 11005, 11411, 11413, 11422, 11426, 11427, 11428, 11429],
    'Southwest Queens'              => [11414, 11415, 11416, 11417, 11418, 11419, 11420, 11421],
    'West Queens'                   => [11368, 11369, 11370, 11372, 11373, 11377, 11378],
    'Port Richmond'                 => [10302, 10303, 10310],
    'South Shore'                   => [10306, 10307, 10308, 10309, 10312],
    'Stapleton and St. George'      => [10301, 10304, 10305],
    'Mid-Island'                    => [10314] }.freeze

  def zip_to_neighborhood(zip)
    res = select_neighborhood_mapping.select { |k, v| k if v.include?(zip.to_i) }
    return res.keys[0] if res
  end

  def neighborhood_to_zip(neighborhood)
    res = select_neighborhood_mapping.select { |k, _v| k == neighborhood }
    res.values[0] if res
  end

  private

    def select_neighborhood_mapping
      case ENV['NEIGHBORHOOD']
      when 'CHICAGO'
        CHICAGO_NEIGHBORHOODS
      when 'NEW_YORK'
        NYC_NEIGHBORHOODS
      else
        NYC_NEIGHBORHOODS
      end
    end

end
