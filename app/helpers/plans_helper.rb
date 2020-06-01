# -*- encoding : utf-8 -*-
module PlansHelper
  # Converte de bytes para megabytes.
  def bytes_to_mb(bytes)
    number_with_precision((bytes / 1.megabyte.to_f), :precision => 2)
  end
end
