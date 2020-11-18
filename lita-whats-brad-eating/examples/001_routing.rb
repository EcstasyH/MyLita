# from lita-whats-brad-eating/lib/lita/handlers/whats_brad_eating.rb
route /^what's brad eating$/i,
	:brad_eats,  #name of handler
	command: true,  #lita handles this
	help: { #help text
	"what's brad eating" => "latest post from brad's food tumblr" }

def brad_eats(response)
    response.reply 'Actual results coming soon!'
end

