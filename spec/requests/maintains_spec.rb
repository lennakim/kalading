require 'spec_helper'
require 'rest_client'

describe '设置汽车保养记录,包括' do
  it '设置汽车外观信息' do
    r = {
      maintain: {
        wheels: [
            {
            name: 'left_front',
            brand: '米其林'
            },
            {
            name: 'sdfs',
            brand: '米其sdfs林'
            }
        ]
      }
    }
    RestClient.put('http://localhost:3000/maintains/53786e7a1298d67653000006', 
    {
      :maintain => {
        :wheels => [
            {
            :name => 'left_front',
            :brand => 'dff'
            },
            {
            :name => 'sdfs',
            :brand => 'sdfsd'
            }
        ]
      }
    })
    
  end
end

