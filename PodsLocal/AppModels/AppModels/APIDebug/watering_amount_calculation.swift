#if DEBUG
/// ``DiagnosisWateringAmountCalculationResponse``
public let watering_amount_calculation_debug: Bool = false
public let watering_amount_calculation_duration: TimeInterval = 10.0
public let watering_amount_calculation =
"""
{
    "is_plant": true,
    "watering_amount_calculation_result": {
        "simple_cms_name": {
            "uid": "0pyvvkq0",
            "taxonomy_type_name": "Species",
            "preferred_name": "Kumquat",
            "main_image_url": "https://cms-cache.AINoteai.com/image/1080/153965579647057941.jpeg",
            "latin_name": "Citrus japonica",
            "cms_static_url": {
                "light_url": "https://cms-cache.AINoteai.com/content/name_h5/1.0.189/ENU/GLOBAL/02282ba30cb07d0bca6fd157d2650c42_light.html",
                "dark_url": "https://cms-cache.AINoteai.com/content/name_h5/1.0.189/ENU/GLOBAL/02282ba30cb07d0bca6fd157d2650c42_dark.html"
            },
            "properties": null,
            "cms_tags": null
        },
        "water_amount": 39.564,
        "care_data": {
            "frequency": 7,
            "care_type": 3
        },
        "cms_topic_groups": [{
            "uid": "oawjxwcm",
            "topic_group_type": 1,
            "tags": [{
                "type": 1,
                "tag_name": "Topic:WateringFAQ",
                "display_tag_name": null,
                "cms_title": null,
                "tag_values": [{
                    "type": 0,
                    "value": "The species known as \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ needs a moderate amount of water compared to most other plants. In most cases, you’ll need to give this plant water about once every week, or when a few inches of soil have dried entirely. With that said, \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is more vulnerable to overwatering than underwatering, so make sure to never give this plant more water than it needs, and it will probably stay healthy for a long time.",
                    "key": "Summary"
                }, {
                    "type": 0,
                    "value": "Your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ will not be too picky about how you choose to water it. As such, you can use just about any common watering tool to moisten this plant’s soil. Watering cans, hoses, and even cups will work just fine when it is time to water your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_. Regardless of which watering tool you use, you should typically apply the water directly to the soil. In doing so, you should ensure that you moisten all soil areas equally to give all parts of the root system the water it needs. It can help to use filtered water, as tap water can contain particles that are harmful to plants. It is also beneficial to use water that is at or slightly above room temperature, as colder or hotter water can be somewhat shocking to the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_. However, the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ usually responds well to any kind of water you give it.",
                    "key": "What is the best way to water my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_?"
                }, {
                    "type": 0,
                    "value": "For outdoor plants, especially newly planted plants or plant seedlings, they can be prone to lack of watering. Remember that you need to keep watering enough for a few months when the tree is small or just planted. This is because once the roots are established, \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ can rely on rain most of the time.\n\nWhen your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is planted in pots, overwatering is often more likely to.When you accidentally overwater your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_, you should be prepared to remedy the situation immediately. First, you should stop watering your plant right away to minimize the effect of your overwatering. After, you should consider removing your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ from its pot to inspect its roots. If you find that none of the roots have developed root rot, it may be permissible to return your plant to its container. If you do discover signs of root rot, then you should trim away any roots that have been affected. You may also want to apply a fungicide to prevent further damage. Lastly, you should repot your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ in soil that is well-draining. In the case of an underwatered \\_\\_YOUR\\_PLANT\\_NAME\\_\\_, simply water this plant more frequently.\n\n\nUnderwatering is often an easy fix. If you underwater, the plant's leaves will tend to droop and dry out and fall off, and the leaves will quickly return to fullness after sufficient watering. Please correct your watering frequency as soon as underwatering occurs.",
                    "key": "What should I do if I water my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ too much or too little?"
                }, {
                    "type": 0,
                    "value": "Most plants that grow naturally outdoors can be allowed to grow normally with rainfall. If your area lacks rainfall, consider giving your plants adequate watering every 2 weeks during the spring and fall. More frequent watering is needed in summer. In winter, when growth becomes slower and plants need less water, water more sparingly. Throughout the winter, you may not give it additional watering at all. If your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is young or newly planted, then you should water more frequently to help it establish, and mature and grow up to have more adaptable and drought tolerant plants.\n\nFor potted plants, there are two main ways that you can determine how often to water your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_. The first way is to set a predetermined watering schedule. If you choose this route, you should plan to water this plant about once every week or once every other week. However, this approach may not always work as it does not consider the unique conditions of the growing environment for your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ .\n\nYour watering frequency can also change depending on the season. For instance, a predetermined watering schedule will likely not suffice during summer when this plant's water needs are highest. An alternative route is to set your watering frequency based on soil moisture. Typically, it is best to wait until the first two to four inches of soil, usually ⅓ to ½ depth of the pots, have dried out entirely before you give more water.",
                    "key": "How often should I water my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_?"
                }, {
                    "type": 0,
                    "value": "When it comes time to water your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_, you may be surprised to find that this plant does not always need a high volume of water. Instead, if only a few inches of soil have dried since your last watering, you can support healthy growth in the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ by giving it about five to ten ounces of water every time you water. You can also decide your water volume based on soil moisture. As mentioned above, you should note how many inches of soil have dried out between waterings. A surefire way to make sure your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ gets the moisture it needs is to supply enough water to moisten all the soil layers that became dry since the last time you watered. If more than half of the soil has become dry, you should consider giving more water than usual. In those cases, continue adding water until you see excess water draining from your pot’s drainage holes.\n\nIf your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is planted in an area that gets plenty of rain outdoors, it may not need additional watering. When the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is young or just getting established, make sure it gets 1-2 inches of rain per week. As it continues to grow and establish, it can survive entirely on rainwater and only when the weather is hot and there is no rainfall at all for 2-3 weeks, then consider giving your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ a full watering to prevent them from suffering stress.",
                    "key": "How much water does my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ need?"
                }, {
                    "type": 0,
                    "value": "Overwatering is a far more common problem for the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_, and there are several signs you should look for when this occurs. Generally, an overwatered \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ will have yellowing leaves and may even drop some leaves. Also, overwatering can cause the overall structure of your plant to shrivel and may also promote root rot. On the other hand, an underwatered \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ will also begin to wilt. It may also display leaves that are brown or brittle to the touch. Whether you see signs of overwatering or underwatering, you should be prepared to intervene and restore the health of your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_.",
                    "key": "How can I tell if i'm watering my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ enough?"
                }, {
                    "type": 0,
                    "value": "When the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is very young, such as when it is in a seedling stage, you will need to give it more water than you would if it were at a mature age. During the early stages of this plant’s life, it is important to keep the soil consistently moist to encourage root development. The same is true for any \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ that you have transplanted to a new growing location. Also, the \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ can develop showy flowers and fruits when you give them the correct care. If your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is in a flowering or fruiting phase, you will likely need to give a bit more water than you usually would to support these plant structures.",
                    "key": "How can I water my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ at different growth stages?"
                }, {
                    "type": 0,
                    "value": "The seasonal changes will affect how often you water your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_. Mainly, during the hottest summer months, you will likely need to increase how much you water this plant, especially if it grows in an area that receives ample sunlight. Strong summer sunlight can cause soil to dry out much faster than usual, meaning that you’ll need to water more frequently. By contrast, your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ will need much less water during the winter, as it will not be in an active growing phase. During winter, you can get by with watering once every 2 to 3 weeks or sometimes not at all. For those growing this plant indoors, you should be somewhat wary of appliances such as air conditioners, which can cause your plant to dry out more quickly, which also calls for more frequent watering.",
                    "key": "How can I water my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ through the seasons?"
                }, {
                    "type": 0,
                    "value": "In some cases, your \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ may not need any supplemental watering when it grows outside and will survive on rainwater alone. However, if you live in an area of little to no rain, you should water this plant about every two weeks. If you belong to the group of people who live out of this plant's natural hardiness zone, you should grow it indoors. In an indoor setting, you should monitor your plant's soil as it can dry out more quickly when it is in a container or when it is exposed to HVAC units such as air conditioners. Those drying factors will lead you to water this plant a bit more often than if you grew it outdoors.",
                    "key": "What's the difference between watering my \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ indoors vs outdoors?"
                }],
                "source_url": null,
                "with_edible_or_medical_info": false
            }, {
                "type": 1,
                "tag_name": "Topic:NoNameWaterFAQ",
                "display_tag_name": null,
                "cms_title": null,
                "tag_values": [{
                    "type": 0,
                    "value": "This plant needs a moderate amount of water compared to most other plants. In most cases, you’ll need to give this plant water about once every week, or when a few inches of soil have dried entirely. With that said, this plant is more vulnerable to overwatering than underwatering, so make sure to never give this plant more water than it needs, and it will probably stay healthy for a long time.",
                    "key": "Summary"
                }, {
                    "type": 0,
                    "value": "This plant will not be too picky about how you choose to water it. As such, you can use just about any common watering tool to moisten this plant’s soil. Watering cans, hoses, and even cups will work just fine when it is time to water your plant. Regardless of which watering tool you use, you should typically apply the water directly to the soil. In doing so, you should ensure that you moisten all soil areas equally to give all parts of the root system the water it needs. It can help to use filtered water, as tap water can contain particles that are harmful to plants. It is also beneficial to use water that is at or slightly above room temperature, as colder or hotter water can be somewhat shocking to this plant. However, it usually responds well to any kind of water you give it.",
                    "key": "What is the best way to water this plant?"
                }, {
                    "type": 0,
                    "value": "For outdoor plants, especially newly planted plants or plant seedlings, they can be prone to lack of watering. Remember that you need to keep watering enough for a few months when the tree is small or just planted. This is because once the roots are established, these plants can rely on rain most of the time.\n\nWhen your plant is planted in pots, overwatering is often more likely to. When you accidentally overwater it, you should be prepared to remedy the situation immediately. First, you should stop watering your plant right away to minimize the effect of your overwatering. After, you should consider removing it from its pot to inspect its roots. If you find that none of the roots have developed root rot, it may be permissible to return your plant to its container. If you do discover signs of root rot, then you should trim away any roots that have been affected. You may also want to apply a fungicide to prevent further damage. Lastly, you should repot your plant in soil that is well-draining. In the case of an underwatered plant, simply water this plant more frequently.\n\nUnderwatering is often an easy fix. If you underwater, the plant's leaves will tend to droop and dry out and fall off, and the leaves will quickly return to fullness after sufficient watering. Please correct your watering frequency as soon as underwatering occurs.",
                    "key": "What should you do if you water this plant too much or too little?"
                }, {
                    "type": 0,
                    "value": "Most plants of this species that grow naturally outdoors can be allowed to grow normally with rainfall. If your area lacks rainfall, consider giving your plants adequate watering every 2 weeks during the spring and fall. More frequent watering is needed in summer. In winter, when growth becomes slower and plants need less water, water more sparingly. Throughout the winter, you may not give it additional watering at all. If your plant is young or newly planted, then you should water more frequently to help it establish, and mature and grow up to have more adaptable and drought tolerant plants.\n\nFor potted plants, there are two main ways that you can determine how often to water this plant. The first way is to set a predetermined watering schedule. If you choose this route, you should plan to water this plant about once every week or once every other week. However, this approach may not always work as it does not consider the unique conditions of the growing environment for your plant.\n\nYour watering frequency can also change depending on the season. For instance, a predetermined watering schedule will likely not suffice during summer when this plant's water needs are highest. An alternative route is to set your watering frequency based on soil moisture. Typically, it is best to wait until the first two to four inches of soil, usually ⅓ to ½ depth of the pots, have dried out entirely before you give more water.",
                    "key": "How often should you water this plant?"
                }, {
                    "type": 0,
                    "value": "When it comes time to water this plant, you may be surprised to find that this plant does not always need a high volume of water. Instead, if only a few inches of soil have dried since your last watering, you can support healthy growth in the plant by giving it about five to ten ounces of water every time you water. You can also decide your water volume based on soil moisture. As mentioned above, you should note how many inches of soil have dried out between waterings. A surefire way to make sure your plant gets the moisture it needs is to supply enough water to moisten all the soil layers that became dry since the last time you watered. If more than half of the soil has become dry, you should consider giving more water than usual. In those cases, continue adding water until you see excess water draining from your pot’s drainage holes.\n\nIf your plant is planted in an area that gets plenty of rain outdoors, it may not need additional watering. When the plant is young or just getting established, make sure it gets 1-2 inches of rain per week. As it continues to grow and establish, it can survive entirely on rainwater and only when the weather is hot and there is no rainfall at all for 2-3 weeks, then consider giving your plant a full watering to prevent them from suffering stress.",
                    "key": "How much do I need to water this plant?"
                }, {
                    "type": 0,
                    "value": "Overwatering is a far more common problem for this plant, and there are several signs you should look for when this occurs. Generally, an overwatered plant will have yellowing leaves and may even drop some leaves. Also, overwatering can cause the overall structure of your plant to shrivel and may also promote root rot. On the other hand, an underwatered plant will also begin to wilt. It may also display leaves that are brown or brittle to the touch. Whether you see signs of overwatering or underwatering, you should be prepared to intervene and restore the health of your plant.",
                    "key": "How do you know if you are watering this plant enough?"
                }, {
                    "type": 0,
                    "value": "When this plant is very young, such as when it is in a seedling stage, you will need to give it more water than you would if it were at a mature age. During the early stages of this plant’s life, it is important to keep the soil consistently moist to encourage root development. The same is true for any plant that you have transplanted to a new growing location. Also, this plant can develop showy flowers and fruits when you give them the correct care. If it is in a flowering or fruiting phase, you will likely need to give a bit more water than you usually would to support these plant structures.",
                    "key": "How should I water this plant at different growth stages?"
                }, {
                    "type": 0,
                    "value": "The seasonal changes will affect how often you water this plant. Mainly, during the hottest summer months, you will likely need to increase how much you water this plant, especially if it grows in an area that receives ample sunlight. Strong summer sunlight can cause soil to dry out much faster than usual, meaning that you’ll need to water more frequently. By contrast, this plant will need much less water during the winter, as it will not be in an active growing phase. During winter, you can get by with watering once every 2 to 3 weeks or sometimes not at all. For those growing this plant indoors, you should be somewhat wary of appliances such as air conditioners, which can cause your plant to dry out more quickly, which also calls for more frequent watering.",
                    "key": "How should I water this plant through the seasons?"
                }, {
                    "type": 0,
                    "value": "In some cases, this plant may not need any supplemental watering when it grows outside and will survive on rainwater alone. However, if you live in an area of little to no rain, you should water this plant about every two weeks. If you belong to the group of people who live out of this plant's natural hardiness zone, you should grow it indoors. In an indoor setting, you should monitor your plant's soil as it can dry out more quickly when it is in a container or when it is exposed to HVAC units such as air conditioners. Those drying factors will lead you to water this plant a bit more often than if you grew it outdoors.",
                    "key": "What is the difference between watering this plant indoors vs. outdoors?"
                }],
                "source_url": null,
                "with_edible_or_medical_info": false
            }, {
                "type": 1,
                "tag_name": "CommonName",
                "display_tag_name": null,
                "cms_title": null,
                "tag_values": [{
                    "type": 0,
                    "value": "oawjxwcm",
                    "key": ""
                }],
                "source_url": null,
                "with_edible_or_medical_info": false
            }],
            "customize_tags": [{
                "tag_id": "CwaterV15",
                "title": "Adapt watering practices to accommodate temperature shifts.",
                "priority": "0",
                "cms_tag": {
                    "type": 1,
                    "tag_name": "Topic:SeasonalWaterTips",
                    "display_tag_name": null,
                    "cms_title": null,
                    "tag_values": [{
                        "type": 0,
                        "value": "As temperatures moderate, adjust your watering routine for \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ to align with its reduced hydration needs. To avert problems like root rot and decay, increase the interval between waterings and be cautious to not overwater.",
                        "key": ""
                    }],
                    "source_url": null,
                    "with_edible_or_medical_info": false
                }
            }, {
                "tag_id": "CwaterV23",
                "title": "A new growth cycle is here! Ensure \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ is well-watered for a strong start.",
                "priority": "2",
                "cms_tag": {
                    "type": 1,
                    "tag_name": "Topic:SeasonalWaterTips",
                    "display_tag_name": null,
                    "cms_title": null,
                    "tag_values": [{
                        "type": 0,
                        "value": "Despite potentially cool evenings, the rise in daytime warmth indicates that \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ will lose moisture more rapidly, necessitating increased watering.",
                        "key": ""
                    }],
                    "source_url": null,
                    "with_edible_or_medical_info": false
                }
            }, {
                "tag_id": "CwaterV24",
                "title": "Ensure continuous hydration for \\_\\_YOUR\\_PLANT\\_NAME\\_\\_ during cooler periods: Store water.",
                "priority": "0",
                "cms_tag": {
                    "type": 1,
                    "tag_name": "Topic:SeasonalWaterTips",
                    "display_tag_name": null,
                    "cms_title": null,
                    "tag_values": [{
                        "type": 0,
                        "value": "It's critical to ensure that outdoor plants, such as \\_\\_YOUR\\_PLANT\\_NAME\\_\\_, receive deep watering prior to periods of sustained low temperatures. When soil becomes frozen, moisture cannot reach deep roots effectively. Despite dormant above-ground activity, these plants require adequate soil moisture to maintain health. Without it, the uppermost portions could wilt from dehydration.",
                        "key": ""
                    }],
                    "source_url": null,
                    "with_edible_or_medical_info": false
                }
            }]
        }]
    }
}
"""
#endif
