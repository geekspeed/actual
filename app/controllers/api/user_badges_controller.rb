class Api::UserBadgesController < ActionController::Base
	respond_to :json

	api :GET, "/api/user_badges/assertion", "Retrive initial data need to define dangerzone"
 	formats [:json]
	def assertion
		program = Program.find_by(id: params[:program_id])
    auth = program.organisation.badge_authority
    user_badge = UserBadge.find(params[:id])
    user = User.find(user_badge.user_id)     
    badge=AppBadge.find(user_badge.app_badge_id)
    badge_url =  badge_api_user_badges_url(app_badge_id: user_badge.app_badge_id, issuer_detail: auth ).to_s
    
    if  user_badge.revoked
      assertion = {
        "revoked" => true
      
      }
      file = File.open(Rails.root.to_s + "/public/bake_badges/#{params[:id]}.json", 'w') { |ee| ee.write(assertion.to_json)}
      render json: assertion, status: 410
    else
      assertion = {
        "uid" => user_badge.id,
        "recipient"=> {
          "type" => "email",
          "hashed" => false, 
          "identity" => user.email
        },
        "issuedOn" => user_badge.created_at,
        "badge" => badge_url,
        "verify" => {
          "type" => "hosted",
          "url" => request.original_url
        }
      }

      file = File.open(Rails.root.to_s + "/public/bake_badges/#{params[:id]}.json", 'w') { |ee| ee.write(assertion.to_json)}
      render json: assertion
    end

  end

 	api :GET, "/api/user_badges/badge", "Retrive initial data need to define dangerzone"
 	formats [:json]

 	def badge
 		 badge=AppBadge.find(params[:app_badge_id])
 		 issur_url = issuer_detail_api_user_badges_url(issuer_detail: params[:issuer_detail]).to_s
 		 badge = {
          "name" => badge.name,
          "description" =>  badge.description,
          "image" =>  root_url + badge.image.authority_image.url,
          "criteria" => root_url + badge.badge_desc.url,
          "issuer" => issur_url
          }
     render json: badge
 	end 

 	api :GET, "/api/user_badges/issuer_detail", "Retrive initial data need to define dangerzone"
 	formats [:json]
 	def issuer_detail
 		detail=BadgeAuthority.find(params[:issuer_detail])
 		issuer = {"name" => detail.name, "url" =>  detail.url} 
 		render json: issuer
 	end
end
