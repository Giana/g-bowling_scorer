local Translations = {
    error = {
        getting_input = 'Error processing input',
        invalid_input = 'Invalid input'
    },
    input = {
        frame = 'Frame',
        submit = 'Submit',
        throw_1 = 'Throw 1 (0-10)',
        throw_2 = 'Throw 2 (0-10)',
        throw_3 = 'Throw 3 (0-10)'
    },
    menu = {
        confirm_score = 'Would you like to score a game of bowling?',
        no = 'No',
        yes = 'Yes'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})